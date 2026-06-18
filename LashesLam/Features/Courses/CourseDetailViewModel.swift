//
//  CourseDetailViewModel.swift
//  LashesLam
//
//  Carga el detalle del curso y el estado de inscripción del usuario, y permite
//  solicitar la inscripción. Espejo de la lógica de cursos en Android.
//

import SwiftUI

@MainActor
final class CourseDetailViewModel: ObservableObject {

    @Published var course: CourseDetail?
    @Published var status: String = CoursesRepository.CourseStatus.requested
    @Published var isLoading = false
    @Published var isRequesting = false
    @Published var errorMessage: String?
    @Published var requestSent = false

    private let courseId: String
    private let repository: CoursesRepository
    private let session = SessionManager.shared

    init(courseId: String, repository: CoursesRepository = CoursesRepository()) {
        self.courseId = courseId
        self.repository = repository
    }

    var statusLabel: String? {
        switch status {
        case CoursesRepository.CourseStatus.pending: return "Solicitud pendiente"
        case CoursesRepository.CourseStatus.accepted: return "¡Inscripción aceptada!"
        case CoursesRepository.CourseStatus.rejected: return "Solicitud rechazada"
        default: return nil
        }
    }

    var canRequest: Bool {
        status == CoursesRepository.CourseStatus.requested ||
        status == CoursesRepository.CourseStatus.rejected
    }

    func load() {
        Task {
            isLoading = true
            async let detail = repository.getCourseById(courseId)
            let userId = session.currentUserId ?? ""
            async let userStatus = repository.getUserCourseStatus(userId: userId, courseId: courseId)

            if case .success(let c) = await detail { course = c }
            status = await userStatus
            isLoading = false
        }
    }

    func requestEnrollment() {
        guard let course, canRequest, !isRequesting else { return }
        Task {
            isRequesting = true
            let result = await repository.createCourseRequest(
                course: course,
                userId: session.currentUserId ?? "",
                userName: session.nameUser ?? "",
                userEmail: session.emailUser ?? ""
            )
            isRequesting = false
            switch result {
            case .success:
                status = CoursesRepository.CourseStatus.pending
                requestSent = true
            case .failure(let error):
                errorMessage = error.userMessage
            }
        }
    }
}
