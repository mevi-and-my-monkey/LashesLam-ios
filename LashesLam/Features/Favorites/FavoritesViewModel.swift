//
//  FavoritesViewModel.swift
//  LashesLam
//
//  Resuelve los favoritos del usuario (productos/cursos/servicios) a partir de
//  los IDs guardados, consultando cada repositorio por IDs.
//

import SwiftUI

@MainActor
final class FavoritesViewModel: ObservableObject {

    @Published var products: [ProductItem] = []
    @Published var courses: [CourseItem] = []
    @Published var services: [ServiceItem] = []
    @Published var isLoading = false

    private let productsRepo = ProductsRepository()
    private let coursesRepo = CoursesRepository()
    private let servicesRepo = ServicesRepository()
    private let favorites = FavoritesManager.shared

    func load() {
        Task {
            isLoading = true
            favorites.load()
            // Da un instante a que cargue el set desde Firestore.
            try? await Task.sleep(nanoseconds: 350_000_000)

            let items = favorites.favorites
            let productIds = items.filter { $0.type == FavoriteType.product.rawValue }.map { $0.itemId }
            let courseIds = items.filter { $0.type == FavoriteType.course.rawValue }.map { $0.itemId }
            let serviceIds = items.filter { $0.type == FavoriteType.service.rawValue }.map { $0.itemId }

            async let p = productsRepo.getProductsByIds(productIds)
            async let c = coursesRepo.getCoursesByIds(courseIds)
            async let s = servicesRepo.getServicesByIds(serviceIds)

            if case .success(let list) = await p { products = list }
            if case .success(let list) = await c { courses = list }
            if case .success(let list) = await s { services = list }
            isLoading = false
        }
    }

    var isEmpty: Bool { products.isEmpty && courses.isEmpty && services.isEmpty }
}
