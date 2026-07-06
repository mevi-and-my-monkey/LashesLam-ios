//
//  ReservationsView.swift
//  LashesLam
//
//  "Mis citas" (usuario) o gestión de citas (admin).
//

import SwiftUI

struct ReservationsView: View {
    let isAdmin: Bool
    @StateObject private var viewModel: ReservationsViewModel

    init(isAdmin: Bool) {
        self.isAdmin = isAdmin
        _viewModel = StateObject(wrappedValue: ReservationsViewModel(isAdmin: isAdmin))
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                if isAdmin { filterChips }

                if viewModel.reservations.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.reservations) { reservation in
                                ReservationCard(
                                    reservation: reservation,
                                    isAdmin: isAdmin,
                                    onAccept: { viewModel.accept(reservation.reservationId) },
                                    onReject: { viewModel.reject(reservation.reservationId) },
                                    onArchive: { viewModel.archive(reservation.reservationId) }
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }

            if viewModel.isLoading { LottieView(name: "loading").frame(width: 100, height: 100) }
        }
        .onAppear { viewModel.load() }
        .refreshable { viewModel.load() }
        .errorDialog($viewModel.errorMessage)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ReservationFilter.allCases) { f in
                    let selected = f == viewModel.filter
                    Text(f.rawValue)
                        .font(.system(size: 14, weight: selected ? .semibold : .regular))
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(selected ? AppColors.onSurface : AppColors.surface)
                        .foregroundColor(selected ? AppColors.onPrimary : AppColors.onSurfaceVariant)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppColors.outline.opacity(0.4), lineWidth: selected ? 0 : 1))
                        .onTapGesture { viewModel.selectFilter(f) }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 8)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "calendar")
                .font(.system(size: 56)).foregroundColor(.gray.opacity(0.4))
            Text(isAdmin ? "Sin citas en esta categoría" : "Aún no tienes citas")
                .font(.subheadline).foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).padding(32)
    }
}
