//
//  SearchView.swift
//  LashesLam
//
//  Búsqueda cross-catálogo (Cursos / Productos / Servicios), igual que SearchPage.kt
//  de Android. Aquí los cursos se muestran TODOS (sin filtro de fecha). Es el destino
//  del buscador del header y del botón "Ver todos".
//

import SwiftUI

struct SearchView: View {
    var initialSection: CatalogSection = .cursos

    @Environment(\.dismiss) private var dismiss
    @StateObject private var coursesVM = CoursesViewModel()
    @StateObject private var productsVM = ProductsViewModel()
    @StateObject private var servicesVM = ServicesViewModel()

    @State private var section: CatalogSection = .cursos
    @State private var query = ""
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            searchHeader

            ScrollView {
                switch section {
                case .cursos: coursesList
                case .productos: productsList
                case .servicios: servicesList
                }
            }
            .background(AppColors.background.ignoresSafeArea())
        }
        .navigationBarHidden(true)
        .onAppear {
            section = initialSection
            if coursesVM.courses.isEmpty { coursesVM.load() }
            if productsVM.products.isEmpty { productsVM.load() }
            if servicesVM.services.isEmpty { servicesVM.load() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true }
        }
    }

    // MARK: - Header

    private var searchHeader: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                }
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundColor(.black)
                    TextField("Buscar…", text: $query)
                        .focused($focused)
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 12)
                .frame(height: 48)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.pinkPrimary.opacity(0.7), lineWidth: 1))
            }

            SectionMenu(selected: $section, onPink: false)
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .background(AppColors.background)
    }

    // MARK: - Listas filtradas

    private var filteredCourses: [CourseItem] {
        guard !query.isEmpty else { return coursesVM.courses }
        return coursesVM.courses.filter { $0.titulo.localizedCaseInsensitiveContains(query) }
    }

    private var filteredProducts: [ProductItem] {
        guard !query.isEmpty else { return productsVM.products }
        return productsVM.products.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    private var filteredServices: [ServiceItem] {
        guard !query.isEmpty else { return servicesVM.services }
        return servicesVM.services.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    private var coursesList: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredCourses) { course in
                ZStack(alignment: .topTrailing) {
                    NavigationLink { CourseDetailView(courseId: course.id) } label: {
                        CourseCard(course: course)
                    }
                    .buttonStyle(.plain)
                    FavoriteHeartButton(itemId: course.id, type: .course).padding(14)
                }
            }
        }
        .padding(16)
    }

    private var productsList: some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(filteredProducts) { product in
                ZStack(alignment: .topTrailing) {
                    NavigationLink { ProductDetailView(product: product) } label: {
                        ProductCard(product: product)
                    }
                    .buttonStyle(.plain)
                    FavoriteHeartButton(itemId: product.id, type: .product).padding(18)
                }
            }
        }
        .padding(16)
    }

    private var servicesList: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredServices) { service in
                ZStack(alignment: .topTrailing) {
                    NavigationLink { ServiceDetailView(service: service) } label: {
                        ServiceCard(service: service)
                    }
                    .buttonStyle(.plain)
                    FavoriteHeartButton(itemId: service.id, type: .service).padding(10)
                }
            }
        }
        .padding(16)
    }
}
