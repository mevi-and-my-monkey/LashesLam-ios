//
//  CatalogHomeView.swift
//  LashesLam
//
//  Home estilo Android: header rosa (perfil + buscador + menú de secciones) y el
//  catálogo de la sección seleccionada (Cursos / Productos / Servicios). El admin
//  tiene un botón flotante para subir curso/producto/servicio.
//

import SwiftUI

struct CatalogHomeView: View {
    @EnvironmentObject var session: SessionManager

    @State private var section: CatalogSection = .cursos
    @State private var searchSection: CatalogSection = .cursos

    @State private var showSearch = false
    @State private var showRequests = false
    @State private var showAddOptions = false
    @State private var showProductForm = false
    @State private var showServiceForm = false
    @State private var showCourseForm = false

    @State private var pendingCount = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    HomeHeaderView(
                        section: $section,
                        pendingCount: pendingCount,
                        onSearch: { searchSection = section; showSearch = true },
                        onRequests: { showRequests = true }
                    )

                    switch section {
                    case .cursos:
                        CoursesView(onSearch: { searchSection = .cursos; showSearch = true })
                    case .productos:
                        ProductsView()
                    case .servicios:
                        ServicesView()
                    }
                }
                .background(AppColors.background.ignoresSafeArea())

                if session.isUserAdmin { addButton }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showSearch) {
                SearchView(initialSection: searchSection)
            }
            .navigationDestination(isPresented: $showRequests) {
                RequestsView(isAdmin: session.isUserAdmin)
            }
            .sheet(isPresented: $showProductForm) { ProductFormView() }
            .sheet(isPresented: $showServiceForm) { ServiceFormView() }
            .sheet(isPresented: $showCourseForm) { CourseFormView() }
            .confirmationDialog("Administrar catálogo", isPresented: $showAddOptions, titleVisibility: .visible) {
                Button("Subir nuevo curso") { showCourseForm = true }
                Button("Subir nuevo producto") { showProductForm = true }
                Button("Subir nuevo servicio") { showServiceForm = true }
                Button("Cancelar", role: .cancel) {}
            }
            .task(id: session.isUserAdmin) { await loadPendingCount() }
        }
    }

    private var addButton: some View {
        Button { showAddOptions = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color(red: 1.0, green: 0.50, blue: 0.67))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
        }
        .padding(24)
    }

    private func loadPendingCount() async {
        guard session.isUserAdmin else { pendingCount = 0; return }
        let result = await CourseRequestRepository().getRequestsByStatus(CoursesRepository.CourseStatus.pending)
        if case .success(let list) = result { pendingCount = list.count }
    }
}
