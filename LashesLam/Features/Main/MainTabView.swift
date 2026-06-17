//
//  MainTabView.swift
//  LashesLam
//
//  Barra de navegación principal. Por ahora con Inicio y Perfil; se irán
//  agregando tabs (tienda, cursos, servicios) conforme se construyan.
//

import SwiftUI

struct MainTabView: View {
    var onLogout: () -> Void

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Inicio", systemImage: "house.fill") }

            ProfilePageView(onLogout: onLogout)
                .tabItem { Label("Perfil", systemImage: "person.fill") }
        }
        .tint(AppColors.pinkPrimary)
    }
}
