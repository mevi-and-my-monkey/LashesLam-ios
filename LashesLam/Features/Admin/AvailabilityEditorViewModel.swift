//
//  AvailabilityEditorViewModel.swift
//  LashesLam
//
//  Editor de disponibilidad de citas (admin). Espejo de la parte de disponibilidad
//  de AdminReservationsViewModel: elige servicio, fecha, agrega/quita/bloquea
//  horarios y guarda en service_availability/{serviceId}.
//

import SwiftUI

struct AvailabilityDay: Identifiable, Hashable {
    var id: String { isoDate }
    let isoDate: String
    let dayLabel: String
    let dayNumber: String
    let monthLabel: String
}

@MainActor
final class AvailabilityEditorViewModel: ObservableObject {

    private static let daysAhead = 60
    private static let dayLabels = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]
    private static let monthLabels = ["Ene", "Feb", "Mar", "Abr", "May", "Jun",
                                      "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"]

    @Published var services: [ServiceItem] = []
    @Published var selectedServiceId: String = ""
    @Published var selectableDays: [AvailabilityDay] = []
    @Published var selectedDate: String = ""
    @Published var schedule: [String: [BookingSlot]] = [:]
    @Published var isLoading = false
    @Published var saved = false
    @Published var errorMessage: String?

    private let bookingRepo = BookingRepository()
    private let servicesRepo = ServicesRepository()

    private static let isoFormatter: DateFormatter = {
        let f = DateFormatter(); f.locale = Locale(identifier: "en_US_POSIX"); f.dateFormat = "yyyy-MM-dd"; return f
    }()

    func load() {
        buildSelectableDays()
        if selectedDate.isEmpty { selectedDate = selectableDays.first?.isoDate ?? "" }
        Task {
            isLoading = true
            if case .success(let list) = await servicesRepo.fetchServices() {
                services = list
                if selectedServiceId.isEmpty { selectedServiceId = list.first?.id ?? "" }
                await loadSchedule()
            }
            isLoading = false
        }
    }

    func selectService(_ id: String) {
        selectedServiceId = id
        Task { await loadSchedule() }
    }

    private func loadSchedule() async {
        guard !selectedServiceId.isEmpty else { return }
        if case .success(let sched) = await bookingRepo.getAvailability(serviceId: selectedServiceId) {
            schedule = sched
        } else {
            schedule = [:]
        }
    }

    private func buildSelectableDays() {
        var days: [AvailabilityDay] = []
        let cal = Calendar.current
        for offset in 0..<Self.daysAhead {
            guard let date = cal.date(byAdding: .day, value: offset, to: Date()) else { continue }
            let weekday = cal.component(.weekday, from: date)
            let mondayIndex = (weekday + 5) % 7
            days.append(AvailabilityDay(
                isoDate: Self.isoFormatter.string(from: date),
                dayLabel: Self.dayLabels[mondayIndex],
                dayNumber: "\(cal.component(.day, from: date))",
                monthLabel: Self.monthLabels[cal.component(.month, from: date) - 1]
            ))
        }
        selectableDays = days
    }

    var slotsForSelectedDate: [BookingSlot] {
        (schedule[selectedDate] ?? []).sorted { $0.time < $1.time }
    }

    func dayHasSlots(_ isoDate: String) -> Bool { !(schedule[isoDate] ?? []).isEmpty }

    func addSlot(_ time: String) {
        let normalized = time.trimmingCharacters(in: .whitespaces)
        guard normalized.range(of: "^\\d{2}:\\d{2}$", options: .regularExpression) != nil else { return }
        var current = schedule[selectedDate] ?? []
        guard !current.contains(where: { $0.time == normalized }) else { return }
        current.append(BookingSlot(time: normalized, occupied: false))
        schedule[selectedDate] = current.sorted { $0.time < $1.time }
    }

    func removeSlot(_ time: String) {
        var current = (schedule[selectedDate] ?? []).filter { $0.time != time }
        if current.isEmpty { schedule.removeValue(forKey: selectedDate) }
        else { schedule[selectedDate] = current }
    }

    func toggleOccupied(_ time: String) {
        guard var current = schedule[selectedDate] else { return }
        current = current.map { $0.time == time ? BookingSlot(time: $0.time, occupied: !$0.occupied) : $0 }
        schedule[selectedDate] = current
    }

    func save() {
        guard !selectedServiceId.isEmpty, !isLoading else { return }
        Task {
            isLoading = true
            let result = await bookingRepo.saveAvailability(serviceId: selectedServiceId, schedule: schedule)
            isLoading = false
            switch result {
            case .success: saved = true
            case .failure(let error): errorMessage = error.userMessage
            }
        }
    }
}
