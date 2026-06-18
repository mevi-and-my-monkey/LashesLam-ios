//
//  CourseRequestsViewModel.swift
//  LashesLam
//
//  Admin: solicitudes de inscripción pendientes con aprobar/rechazar.
//  Espejo de AdminRequestsViewModel (lado cursos).
//

import SwiftUI

@MainActor
final class CourseRequestsViewModel: ObservableObject {

    @Published var requests: [CourseRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: CourseRequestRepository

    init(repository: CourseRequestRepository = CourseRequestRepository()) {
        self.repository = repository
    }

    func load() {
        Task {
            isLoading = true
            // Las solicitudes solo existen mientras están pendientes.
            let result = await repository.getRequestsByStatus(CoursesRepository.CourseStatus.pending)
            isLoading = false
            switch result {
            case .success(let list): requests = list
            case .failure(let error): errorMessage = error.userMessage
            }
        }
    }

    func approve(_ requestId: String) { update { await self.repository.approveRequest(requestId) } }
    func reject(_ requestId: String) { update { await self.repository.rejectRequest(requestId) } }

    private func update(_ action: @escaping () async -> Resource<Bool>) {
        Task {
            isLoading = true
            _ = await action()
            isLoading = false
            load()
        }
    }
}
