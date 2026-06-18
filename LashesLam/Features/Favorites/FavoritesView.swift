//
//  FavoritesView.swift
//  LashesLam
//
//  Favoritos del usuario con selector Productos / Cursos / Servicios.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @ObservedObject private var favorites = FavoritesManager.shared

    enum Section: String, CaseIterable, Identifiable {
        case productos = "Productos"
        case cursos = "Cursos"
        case servicios = "Servicios"
        var id: String { rawValue }
    }
    @State private var section: Section = .productos

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(spacing: 0) {
            Picker("Sección", selection: $section) {
                ForEach(Section.allCases) { s in Text(s.rawValue).tag(s) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16).padding(.vertical, 8)

            ScrollView {
                switch section {
                case .productos: productsGrid
                case .cursos: coursesList
                case .servicios: servicesList
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Favoritos")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoading { ProgressView().tint(AppColors.pinkPrimary) }
            else if viewModel.isEmpty { emptyState }
        }
        .onAppear { viewModel.load() }
        // Recarga al cambiar favoritos desde otras pantallas.
        .onChange(of: favorites.favoriteIds) { _ in viewModel.load() }
    }

    private var productsGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.products) { product in
                ZStack(alignment: .topTrailing) {
                    NavigationLink { ProductDetailView(product: product) } label: { ProductCard(product: product) }
                        .buttonStyle(.plain)
                    FavoriteHeartButton(itemId: product.id, type: .product).padding(18)
                }
            }
        }
        .padding(16)
    }

    private var coursesList: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.courses) { course in
                ZStack(alignment: .topTrailing) {
                    NavigationLink { CourseDetailView(courseId: course.id) } label: { CourseCard(course: course) }
                        .buttonStyle(.plain)
                    FavoriteHeartButton(itemId: course.id, type: .course).padding(14)
                }
            }
        }
        .padding(16)
    }

    private var servicesList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.services) { service in
                ZStack(alignment: .topTrailing) {
                    NavigationLink { ServiceDetailView(service: service) } label: { ServiceCard(service: service) }
                        .buttonStyle(.plain)
                    FavoriteHeartButton(itemId: service.id, type: .service).padding(10)
                }
            }
        }
        .padding(16)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart").font(.system(size: 56)).foregroundColor(.gray.opacity(0.4))
            Text("Aún no tienes favoritos").font(.subheadline).foregroundColor(.gray)
        }
        .padding(32)
    }
}
