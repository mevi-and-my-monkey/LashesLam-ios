//
//  BookingViewModel.swift
//  LashesLam
//
//  Espejo de ui/booking/BookingViewModel.kt. Construye los días disponibles a
//  partir de la disponibilidad, calcula horarios tomados y crea la reserva.
//

import SwiftUI

/// Día seleccionable en la pantalla de reserva.
struct BookingDay: Identifiable, Hashable {
    var id: String { isoDate }
    let isoDate: String     // 2026-06-19
    let dayLabel: String    // Vie
    let dayNumber: String   // 19
    let monthLabel: String  // JUNIO 2026
}

@MainActor
final class BookingViewModel: ObservableObject {

    private static let dayLabels = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]
    private static let monthLabels = ["ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO",
                                      "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"]

    @Published var availableDays: [BookingDay] = []
    @Published var slots: [String] = []
    @Published var takenSlots: [String] = []
    @Published var selectedDate: BookingDay?
    @Published var selectedTime: String?
    @Published var isLoading = false
    @Published var reservationPlaced: ServiceReservation?
    @Published var errorMessage: String?

    let service: ServiceItem
    private var schedule: [String: [BookingSlot]] = [:]
    private var daySlots: [BookingSlot] = []

    private let repository: BookingRepository
    private let session = SessionManager.shared

    private static let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init(service: ServiceItem, repository: BookingRepository = BookingRepository()) {
        self.service = service
        self.repository = repository
    }

    func load() {
        Task {
            isLoading = true
            let result = await repository.getAvailability(serviceId: service.id)
            isLoading = false
            if case .success(let sched) = result {
                schedule = sched
                buildAvailableDays()
            }
        }
    }

    private func buildAvailableDays() {
        let todayIso = Self.isoFormatter.string(from: Date())
        availableDays = schedule
            .filter { $0.key >= todayIso && $0.value.contains { !$0.occupied } }
            .keys.sorted()
            .compactMap { buildBookingDay($0) }
    }

    private func buildBookingDay(_ isoDate: String) -> BookingDay? {
        guard let date = Self.isoFormatter.date(from: isoDate) else { return nil }
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)       // 1=Dom..7=Sáb
        let mondayIndex = (weekday + 5) % 7                      // 0=Lun..6=Dom
        let month = cal.component(.month, from: date)
        let year = cal.component(.year, from: date)
        return BookingDay(
            isoDate: isoDate,
            dayLabel: Self.dayLabels[mondayIndex],
            dayNumber: "\(cal.component(.day, from: date))",
            monthLabel: "\(Self.monthLabels[month - 1]) \(year)"
        )
    }

    func selectDate(_ day: BookingDay) {
        selectedDate = day
        selectedTime = nil
        daySlots = schedule[day.isoDate] ?? []
        slots = daySlots.map { $0.time }
        takenSlots = daySlots.filter { $0.occupied }.map { $0.time }

        Task {
            let result = await repository.getTakenSlots(serviceId: service.id, date: day.isoDate)
            if case .success(let taken) = result {
                takenSlots = Array(Set(takenSlots + taken))
            }
        }
    }

    func selectTime(_ time: String) {
        guard !takenSlots.contains(time) else { return }
        selectedTime = time
    }

    func confirmReservation(onOpenWhatsApp: @escaping (URL) -> Void) {
        guard let day = selectedDate, let time = selectedTime, !isLoading else { return }
        Task {
            isLoading = true
            let label = "\(day.dayLabel) \(day.dayNumber) " +
                day.monthLabel.lowercased().prefix(1).uppercased() + day.monthLabel.lowercased().dropFirst()
            let reservation = ServiceReservation(
                serviceId: service.id,
                serviceName: service.title,
                durationLabel: Formatters.serviceDuration(service.duration),
                price: service.price,
                userId: session.currentUserId ?? "",
                nameUser: session.nameUser ?? "",
                emailUser: session.emailUser ?? "",
                date: day.isoDate,
                dateLabel: label,
                time: time
            )
            let result = await repository.createReservation(reservation)
            isLoading = false
            switch result {
            case .success(let placed):
                reservationPlaced = placed
                let whatsapp = (session.whatsApp?.isEmpty == false) ? session.whatsApp! : "5514023853"
                if let url = Formatters.whatsAppReservationURL(reservation: placed, whatsapp: whatsapp) {
                    onOpenWhatsApp(url)
                }
            case .failure(let error):
                errorMessage = error.userMessage
            }
        }
    }
}
