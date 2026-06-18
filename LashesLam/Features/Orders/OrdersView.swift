//
//  OrdersView.swift
//  LashesLam
//
//  "Mis pedidos" (usuario) o gestión de pedidos (admin), según el rol.
//

import SwiftUI

struct OrdersView: View {
    let isAdmin: Bool
    @StateObject private var viewModel: OrdersViewModel

    init(isAdmin: Bool) {
        self.isAdmin = isAdmin
        _viewModel = StateObject(wrappedValue: OrdersViewModel(isAdmin: isAdmin))
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                if isAdmin { filterChips }

                if viewModel.orders.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.orders) { order in
                                OrderCard(
                                    order: order,
                                    isAdmin: isAdmin,
                                    onComplete: { viewModel.completeOrder(order.orderId) },
                                    onArchive: { viewModel.archiveOrder(order.orderId) }
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }

            if viewModel.isLoading {
                ProgressView().tint(AppColors.pinkPrimary)
            }
        }
        .onAppear { viewModel.load() }
        .refreshable { viewModel.load() }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } })
        ) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "") }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(OrderFilter.allCases) { f in
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
            Image(systemName: "shippingbox")
                .font(.system(size: 56)).foregroundColor(.gray.opacity(0.4))
            Text(isAdmin ? "Sin pedidos en esta categoría" : "Aún no tienes pedidos")
                .font(.subheadline).foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}
