//
//  CatalogHomeView.swift
//  LashesLam
//
//  Home estilo Android: encabezado + selector de secciones (Cursos / Productos /
//  Servicios) que muestra el catálogo correspondiente. Un único NavigationStack
//  para todo el catálogo.
//

import SwiftUI

struct CatalogHomeView: View {
    @EnvironmentObject var session: SessionManager

    enum Section: String, CaseIterable, Identifiable {
        case cursos = "Cursos"
        case productos = "Productos"
        case servicios = "Servicios"
        var id: String { rawValue }
    }

    @State private var section: Section = .cursos
    @State private var showProductForm = false
    @State private var showServiceForm = false
    @State private var showCourseForm = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                sectionPicker

                switch section {
                case .cursos:    CoursesView()
                case .productos: ProductsView()
                case .servicios: ServicesView()
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("LashesLam")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if session.isUserAdmin {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { onAdminAdd() } label: { Image(systemName: "plus") }
                    }
                }
            }
            .sheet(isPresented: $showProductForm) { ProductFormView() }
            .sheet(isPresented: $showServiceForm) { ServiceFormView() }
            .sheet(isPresented: $showCourseForm) { CourseFormView() }
        }
    }

    private func onAdminAdd() {
        switch section {
        case .productos: showProductForm = true
        case .servicios: showServiceForm = true
        case .cursos: showCourseForm = true
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image("logo_app")
                .resizable().scaledToFit()
                .frame(width: 44, height: 44).clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("¡Hola, \(session.nameUser ?? "bienvenida")!")
                    .font(.appTitleMedium(20)).italic()
                    .foregroundColor(AppColors.onBackground)
                if session.isUserAdmin {
                    Label("Administradora", systemImage: "crown.fill")
                        .font(.caption2.bold())
                        .foregroundColor(AppColors.purpleSecondary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 4)
    }

    private var sectionPicker: some View {
        Picker("Sección", selection: $section) {
            ForEach(Section.allCases) { s in Text(s.rawValue).tag(s) }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16).padding(.vertical, 8)
    }
}
