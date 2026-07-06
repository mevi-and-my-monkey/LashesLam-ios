//
//  CoursesViewModel.swift
//  LashesLam
//
//  Lista de cursos.
//

import SwiftUI

@MainActor
final class CoursesViewModel: ObservableObject {

    @Published var courses: [CourseItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Solo cursos de fecha futura (>= hoy), ordenados por fecha. Igual que el
    /// filtro del Home en Android (HomePageViewModel: date >= today, sortedBy date).
    var futureCourses: [CourseItem] {
        let today = Calendar.current.startOfDay(for: Date())
        return courses
            .filter { ($0.parsedDate ?? .distantPast) >= today }
            .sorted { ($0.parsedDate ?? .distantPast) < ($1.parsedDate ?? .distantPast) }
    }

    private let repository: CoursesRepository

    init(repository: CoursesRepository = CoursesRepository()) {
        self.repository = repository
        NotificationCenter.default.addObserver(forName: .catalogDidChange, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.load() }
        }
    }

    func load() {
        Task {
            isLoading = true
            let result = await repository.fetchCourses()
            isLoading = false
            switch result {
            case .success(let items): courses = items
            case .failure(let error): errorMessage = error.userMessage
            }
        }
    }
}
