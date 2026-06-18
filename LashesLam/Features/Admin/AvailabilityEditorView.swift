//
//  AvailabilityEditorView.swift
//  LashesLam
//
//  Editor de disponibilidad de citas (admin): por servicio y fecha, agrega/quita
//  horarios y los marca como ocupados.
//

import SwiftUI

struct AvailabilityEditorView: View {
    @StateObject private var viewModel = AvailabilityEditorViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var newSlotTime = Date()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter(); f.locale = Locale(identifier: "en_US_POSIX"); f.dateFormat = "HH:mm"; return f
    }()

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                servicePicker
                daysRow
                Divider()
                addSlotBar
                slotsList
            }

            if viewModel.isLoading {
                ZStack { Color.black.opacity(0.15).ignoresSafeArea(); ProgressView().tint(AppColors.pinkPrimary) }
            }
        }
        .navigationTitle("Disponibilidad")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") { viewModel.save() }
            }
        }
        .onAppear { viewModel.load() }
        .onChange(of: viewModel.saved) { if $0 { dismiss() } }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } })
        ) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "") }
    }

    private var servicePicker: some View {
        HStack {
            Text("Servicio").font(.subheadline.bold())
            Spacer()
            Picker("Servicio", selection: Binding(
                get: { viewModel.selectedServiceId },
                set: { viewModel.selectService($0) })
            ) {
                ForEach(viewModel.services) { s in Text(s.title).tag(s.id) }
            }
            .pickerStyle(.menu)
            .tint(AppColors.pinkPrimary)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
    }

    private var daysRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.selectableDays) { day in
                    let selected = day.isoDate == viewModel.selectedDate
                    VStack(spacing: 3) {
                        Text(day.dayLabel).font(.caption2.bold())
                        Text(day.dayNumber).font(.headline)
                        Text(day.monthLabel).font(.caption2)
                        Circle()
                            .fill(viewModel.dayHasSlots(day.isoDate) ? AppColors.pinkPrimary : .clear)
                            .frame(width: 6, height: 6)
                    }
                    .frame(width: 56, height: 78)
                    .background(selected ? AppColors.pinkPrimary.opacity(0.15) : AppColors.surface)
                    .foregroundColor(selected ? AppColors.pinkPrimary : AppColors.onSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14)
                        .stroke(selected ? AppColors.pinkPrimary : AppColors.outline.opacity(0.3), lineWidth: 1))
                    .onTapGesture { viewModel.selectedDate = day.isoDate }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
        }
    }

    private var addSlotBar: some View {
        HStack(spacing: 12) {
            DatePicker("", selection: $newSlotTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
            Button {
                viewModel.addSlot(Self.timeFormatter.string(from: newSlotTime))
            } label: {
                Label("Agregar horario", systemImage: "plus.circle.fill")
                    .font(.subheadline.bold())
            }
            .tint(AppColors.pinkPrimary)
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
    }

    private var slotsList: some View {
        ScrollView {
            if viewModel.slotsForSelectedDate.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "clock.badge.questionmark")
                        .font(.system(size: 44)).foregroundColor(.gray.opacity(0.4))
                    Text("Sin horarios este día").font(.subheadline).foregroundColor(.gray)
                    Text("Agrega horarios con el botón de arriba.").font(.caption).foregroundColor(.gray)
                }
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.slotsForSelectedDate, id: \.time) { slot in
                        HStack {
                            Text(slot.time).font(.headline)
                            Spacer()
                            Button { viewModel.toggleOccupied(slot.time) } label: {
                                Text(slot.occupied ? "Bloqueado" : "Libre")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(slot.occupied ? Color.red.opacity(0.15) : Color.green.opacity(0.15))
                                    .foregroundColor(slot.occupied ? .red : .green)
                                    .clipShape(Capsule())
                            }
                            Button { viewModel.removeSlot(slot.time) } label: {
                                Image(systemName: "trash").foregroundColor(.gray)
                            }
                        }
                        .padding(14)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(16)
            }
        }
    }
}
