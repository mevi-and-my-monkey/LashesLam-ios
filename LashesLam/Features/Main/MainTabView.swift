//
//  MainTabView.swift
//  LashesLam
//
//  Barra de navegación principal, estilo Android: Inicio (catálogo con secciones
//  Cursos/Productos/Servicios), Carrito (no-admin) y Perfil.
//

import SwiftUI

struct MainTabView: View {
    var onLogout: () -> Void

    @EnvironmentObject var session: SessionManager
    @ObservedObject private var cart = CartManager.shared

    var body: some View {
        TabView {
            CatalogHomeView()
                .tabItem { Label("Inicio", systemImage: "house.fill") }

            // El carrito se oculta para administradores, igual que en Android.
            if !session.isUserAdmin {
                CartView()
                    .tabItem { Label("Carrito", systemImage: "cart.fill") }
                    .badge(cart.count)
            }

            ProfilePageView(onLogout: onLogout)
                .tabItem { Label("Perfil", systemImage: "person.fill") }
        }
        .tint(AppColors.pinkPrimary)
    }
}
