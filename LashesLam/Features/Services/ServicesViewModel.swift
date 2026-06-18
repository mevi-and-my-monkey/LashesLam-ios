//
//  ServicesViewModel.swift
//  LashesLam
//
//  Carga servicios y categorías con filtro por categoría (default "all"),
//  espejo de la lógica de servicios en HomePageViewModel (Android).
//

import SwiftUI

@MainActor
final class ServicesViewModel: ObservableObject {

    @Published var services: [ServiceItem] = []
    @Published var filteredServices: [ServiceItem] = []
    @Published var categories: [CategoryModel] = [.all]
    @Published var selectedCategoryId: String = CategoryModel.all.id
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: ServicesRepository

    init(repository: ServicesRepository = ServicesRepository()) {
        self.repository = repository
    }

    func load() {
        Task {
            isLoading = true
            async let servicesResult = repository.fetchServices()
            async let categoriesResult = repository.fetchCategories()

            switch await servicesResult {
            case .success(let items):
                services = items
                applyFilter()
            case .failure(let error):
                errorMessage = error.userMessage
            }
            if case .success(let cats) = await categoriesResult {
                categories = [.all] + cats
            }
            isLoading = false
        }
    }

    func selectCategory(_ category: CategoryModel) {
        selectedCategoryId = category.id
        applyFilter()
    }

    private func applyFilter() {
        if selectedCategoryId == CategoryModel.all.id {
            filteredServices = services
        } else {
            filteredServices = services.filter {
                $0.category.caseInsensitiveCompare(selectedCategoryId) == .orderedSame
            }
        }
    }
}
