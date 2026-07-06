//
//  FavoritesView.swift
//  LashesLam
//
//  Favoritos del usuario. Solo muestra Cursos y Productos (en ese orden), con las
//  tarjetas de favoritos dedicadas (FavoriteCourseCard / FavoriteProductCard).
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @ObservedObject private var favorites = FavoritesManager.shared

    enum Section: String, CaseIterable, Identifiable {
        case cursos = "Cursos"
        case productos = "Productos"
        var id: String { rawValue }
    }
    @State private var section: Section = .cursos

    var body: some View {
        VStack(spacing: 0) {
            Picker("Sección", selection: $section) {
                ForEach(Section.allCases) { s in Text(s.rawValue).tag(s) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16).padding(.vertical, 8)

            ScrollView {
                switch section {
                case .cursos: coursesList
                case .productos: productsList
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Favoritos")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoading { LottieView(name: "loading").frame(width: 100, height: 100) }
            else if isCurrentSectionEmpty { emptyState }
        }
        .onAppear { viewModel.load() }
        .onChange(of: favorites.favoriteIds) { _ in viewModel.load() }
    }

    private var isCurrentSectionEmpty: Bool {
        switch section {
        case .cursos: return viewModel.courses.isEmpty
        case .productos: return viewModel.products.isEmpty
        }
    }

    private var coursesList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.courses) { course in
                NavigationLink { CourseDetailView(courseId: course.id) } label: {
                    FavoriteCourseCard(course: course)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
    }

    private var productsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.products) { product in
                NavigationLink { ProductDetailView(product: product) } label: {
                    FavoriteProductCard(product: product)
                }
                .buttonStyle(.plain)
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
