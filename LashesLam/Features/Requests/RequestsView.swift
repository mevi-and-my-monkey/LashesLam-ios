//
//  RequestsView.swift
//  LashesLam
//
//  Pantalla unificada de pedidos/solicitudes con selector de secciones
//  (Productos / Cursos / Servicios), igual que Android. Sirve para usuario y admin.
//

import SwiftUI

struct RequestsView: View {
    let isAdmin: Bool

    enum Section: String, CaseIterable, Identifiable {
        case cursos = "Cursos"
        case productos = "Productos"
        case servicios = "Servicios"
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

            switch section {
            case .productos:
                OrdersView(isAdmin: isAdmin)
            case .cursos:
                if isAdmin { CourseRequestsView() } else { UserCoursesView() }
            case .servicios:
                ReservationsView(isAdmin: isAdmin)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(isAdmin ? "Solicitudes" : "Mis pedidos")
        .navigationBarTitleDisplayMode(.inline)
    }
}
