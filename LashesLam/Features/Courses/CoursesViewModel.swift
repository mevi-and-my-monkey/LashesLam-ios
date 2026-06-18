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
