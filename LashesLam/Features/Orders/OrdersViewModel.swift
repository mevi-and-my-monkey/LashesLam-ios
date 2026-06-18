//
//  OrdersViewModel.swift
//  LashesLam
//
//  Espejo de ui/requestuser/AdminRequestsUserViewModel (usuario) y
//  ui/profile/request/AdminProductOrdersViewModel (admin). Carga las órdenes y,
//  en modo admin, permite filtrar y cambiar estado.
//

import SwiftUI

/// Filtro de órdenes para administrador (igual que OrderFilter de Android).
enum OrderFilter: String, CaseIterable, Identifiable {
    case todos = "Todos"
    case pendiente = "Pendiente"
    case completado = "Completado"
    case archivado = "Archivado"
    var id: String { rawValue }

    var statuses: [String] {
        switch self {
        case .todos:
            return [ProductOrderRepository.Status.pending,
                    ProductOrderRepository.Status.completed,
                    ProductOrderRepository.Status.legacyAccepted]
        case .pendiente:
            return [ProductOrderRepository.Status.pending]
        case .completado:
            return [ProductOrderRepository.Status.completed,
                    ProductOrderRepository.Status.legacyAccepted]
        case .archivado:
            return [ProductOrderRepository.Status.archived]
        }
    }
}

@MainActor
final class OrdersViewModel: ObservableObject {

    @Published var orders: [ProductOrder] = []
    @Published var filter: OrderFilter = .todos
    @Published var isLoading = false
    @Published var errorMessage: String?

    let isAdmin: Bool
    private let session = SessionManager.shared
    private let repository: ProductOrderRepository

    init(isAdmin: Bool, repository: ProductOrderRepository = ProductOrderRepository()) {
        self.isAdmin = isAdmin
        self.repository = repository
    }

    func load() {
        Task {
            isLoading = true
            let result: Resource<[ProductOrder]>
            if isAdmin {
                result = await repository.getOrdersByStatus(filter.statuses)
            } else {
                result = await repository.getOrdersByUser(userId: session.currentUserId ?? "")
            }
            isLoading = false
            switch result {
            case .success(let list): orders = list
            case .failure(let error): errorMessage = error.userMessage; orders = []
            }
        }
    }

    func selectFilter(_ newFilter: OrderFilter) {
        filter = newFilter
        load()
    }

    func completeOrder(_ orderId: String) { updateStatus(orderId, ProductOrderRepository.Status.completed) }
    func archiveOrder(_ orderId: String) { updateStatus(orderId, ProductOrderRepository.Status.archived) }

    private func updateStatus(_ orderId: String, _ status: String) {
        Task {
            isLoading = true
            _ = await repository.updateStatus(orderId: orderId, status: status)
            isLoading = false
            load()
        }
    }
}
