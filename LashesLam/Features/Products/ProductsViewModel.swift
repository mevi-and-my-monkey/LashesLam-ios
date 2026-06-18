//
//  ProductsViewModel.swift
//  LashesLam
//
//  Carga productos y categorías y aplica el filtro por categoría, igual que
//  la lógica de HomePageViewModel (Android): default "all", best selling, etc.
//

import SwiftUI

@MainActor
final class ProductsViewModel: ObservableObject {

    @Published var products: [ProductItem] = []
    @Published var filteredProducts: [ProductItem] = []
    @Published var bestSellingProducts: [ProductItem] = []
    @Published var categories: [CategoryModel] = [.all]
    @Published var selectedCategoryId: String = CategoryModel.all.id  // "all"
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: ProductsRepository

    init(repository: ProductsRepository = ProductsRepository()) {
        self.repository = repository
        NotificationCenter.default.addObserver(forName: .catalogDidChange, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.load() }
        }
    }

    func load() {
        Task {
            isLoading = true
            async let productsResult = repository.fetchProducts()
            async let categoriesResult = repository.fetchCategories()

            switch await productsResult {
            case .success(let items):
                products = items
                bestSellingProducts = items.filter { $0.bestSelling }
                applyFilter()
            case .failure(let error):
                errorMessage = error.userMessage
            }

            if case .success(let cats) = await categoriesResult {
                // Anteponemos "Todos" para poder limpiar el filtro.
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
            filteredProducts = products
        } else {
            filteredProducts = products.filter {
                $0.category.caseInsensitiveCompare(selectedCategoryId) == .orderedSame
            }
        }
    }
}
