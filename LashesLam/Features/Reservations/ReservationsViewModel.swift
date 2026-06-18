//
//  ReservationsViewModel.swift
//  LashesLam
//
//  Espejo de ui/requestuser (usuario) y AdminReservationsViewModel (admin).
//  Lista las citas y, en modo admin, permite filtrar y cambiar el estado.
//

import SwiftUI

enum ReservationFilter: String, CaseIterable, Identifiable {
    case todos = "Todos"
    case pendiente = "Pendiente"
    case agendado = "Agendado"
    case cancelado = "Cancelado"
    case archivado = "Archivado"
    var id: String { rawValue }

    var statuses: [String] {
        switch self {
        case .todos:
            return [BookingRepository.Status.pending,
                    BookingRepository.Status.scheduled,
                    BookingRepository.Status.cancelled]
        case .pendiente: return [BookingRepository.Status.pending]
        case .agendado:  return [BookingRepository.Status.scheduled]
        case .cancelado: return [BookingRepository.Status.cancelled]
        case .archivado: return [BookingRepository.Status.archived]
        }
    }
}

@MainActor
final class ReservationsViewModel: ObservableObject {

    @Published var reservations: [ServiceReservation] = []
    @Published var filter: ReservationFilter = .todos
    @Published var isLoading = false
    @Published var errorMessage: String?

    let isAdmin: Bool
    private let session = SessionManager.shared
    private let repository: BookingRepository

    init(isAdmin: Bool, repository: BookingRepository = BookingRepository()) {
        self.isAdmin = isAdmin
        self.repository = repository
    }

    func load() {
        Task {
            isLoading = true
            let result: Resource<[ServiceReservation]>
            if isAdmin {
                result = await repository.getReservationsByStatus(filter.statuses)
            } else {
                result = await repository.getReservationsByUser(userId: session.currentUserId ?? "")
            }
            isLoading = false
            switch result {
            case .success(let list): reservations = list
            case .failure(let error): errorMessage = error.userMessage; reservations = []
            }
        }
    }

    func selectFilter(_ newFilter: ReservationFilter) {
        filter = newFilter
        load()
    }

    func accept(_ id: String)  { updateStatus(id, BookingRepository.Status.scheduled) }
    func reject(_ id: String)  { updateStatus(id, BookingRepository.Status.cancelled) }
    func archive(_ id: String) { updateStatus(id, BookingRepository.Status.archived) }

    private func updateStatus(_ id: String, _ status: String) {
        Task {
            isLoading = true
            _ = await repository.updateStatus(reservationId: id, status: status)
            isLoading = false
            load()
        }
    }
}
