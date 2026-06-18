//
//  BookingView.swift
//  LashesLam
//
//  Agendamiento de cita: elige fecha y horario disponible y confirma la reserva.
//  Espejo de ui/booking/BookingScreen.kt.
//

import SwiftUI

struct BookingView: View {
    let service: ServiceItem
    @StateObject private var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss

    private let slotColumns = [GridItem(.adaptive(minimum: 80), spacing: 10)]

    init(service: ServiceItem) {
        self.service = service
        _viewModel = StateObject(wrappedValue: BookingViewModel(service: service))
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if let reservation = viewModel.reservationPlaced {
                confirmation(reservation)
            } else if viewModel.availableDays.isEmpty && !viewModel.isLoading {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Elige una fecha").font(.headline).padding(.horizontal, 16)
                        daysRow

                        if viewModel.selectedDate != nil {
                            Text("Elige un horario").font(.headline).padding(.horizontal, 16)
                            slotsGrid
                        }
                    }
                    .padding(.vertical, 12)
                }

                if viewModel.selectedTime != nil {
                    VStack { Spacer(); confirmBar }
                }
            }

            if viewModel.isLoading {
                ZStack { Color.black.opacity(0.15).ignoresSafeArea(); ProgressView().tint(AppColors.pinkPrimary) }
            }
        }
        .navigationTitle("Agendar cita")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.load() }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } })
        ) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "") }
    }

    private var daysRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.availableDays) { day in
                    let selected = day.id == viewModel.selectedDate?.id
                    VStack(spacing: 4) {
                        Text(day.dayLabel).font(.caption.bold())
                        Text(day.dayNumber).font(.title3.bold())
                    }
                    .frame(width: 60, height: 70)
                    .background(selected ? AppColors.pinkPrimary : AppColors.surface)
                    .foregroundColor(selected ? .white : AppColors.onSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.outline.opacity(0.3), lineWidth: selected ? 0 : 1))
                    .onTapGesture { viewModel.selectDate(day) }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var slotsGrid: some View {
        LazyVGrid(columns: slotColumns, spacing: 10) {
            ForEach(viewModel.slots, id: \.self) { time in
                let taken = viewModel.takenSlots.contains(time)
                let selected = time == viewModel.selectedTime
                Text(time)
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                    .background(slotBackground(taken: taken, selected: selected))
                    .foregroundColor(taken ? .gray : (selected ? .white : AppColors.onSurface))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(taken ? nil : RoundedRectangle(cornerRadius: 12).stroke(AppColors.outline.opacity(0.3), lineWidth: selected ? 0 : 1))
                    .strikethrough(taken)
                    .onTapGesture { if !taken { viewModel.selectTime(time) } }
            }
        }
        .padding(.horizontal, 16)
    }

    private func slotBackground(taken: Bool, selected: Bool) -> Color {
        if taken { return Color.gray.opacity(0.15) }
        if selected { return AppColors.pinkPrimary }
        return AppColors.surface
    }

    private var confirmBar: some View {
        Button {
            viewModel.confirmReservation { url in UIApplication.shared.open(url) }
        } label: {
            Text("Confirmar cita").fontWeight(.bold)
                .frame(maxWidth: .infinity).padding()
                .background(AppColors.pinkPrimary).foregroundColor(.white)
                .clipShape(Capsule())
        }
        .padding(16)
        .background(.ultraThinMaterial)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 56)).foregroundColor(.gray.opacity(0.4))
            Text("Sin horarios disponibles").font(.headline)
            Text("Por ahora no hay fechas disponibles para este servicio.")
                .font(.subheadline).foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }

    private func confirmation(_ reservation: ServiceReservation) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80)).foregroundColor(AppColors.pinkPrimary)
            Text("¡Cita solicitada!").font(.appTitle(28)).foregroundColor(.black)
            Text("Te contactaremos por WhatsApp para confirmar tu cita.")
                .font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center)

            VStack(spacing: 6) {
                Text("#\(reservation.reservationNumber)").font(.headline)
                Text("\(reservation.dateLabel) · \(reservation.time)").font(.subheadline).foregroundColor(.gray)
            }
            .padding().frame(maxWidth: .infinity)
            .background(AppColors.surface).cornerRadius(16)

            Button { dismiss() } label: {
                Text("Listo").fontWeight(.bold)
                    .frame(maxWidth: .infinity).padding()
                    .background(Color(red: 0.11, green: 0.11, blue: 0.11))
                    .foregroundColor(.white).clipShape(Capsule())
            }
            Spacer()
        }
        .padding(24)
    }
}
