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

            // Favoritos y Carrito solo para usuarios (no admin), igual que Android.
            if !session.isUserAdmin {
                NavigationStack { FavoritesView() }
                    .tabItem { Label("Favoritos", systemImage: "heart.fill") }

                CartView()
                    .tabItem { Label("Carrito", systemImage: "cart.fill") }
                    .badge(cart.count)
            }

            // "Ordenes": solicitudes (admin) / mis pedidos (usuario). Presente en ambos.
            NavigationStack { RequestsView(isAdmin: session.isUserAdmin) }
                .tabItem { Label("Ordenes", systemImage: "bag.fill") }

            ProfilePageView(onLogout: onLogout)
                .tabItem { Label("Perfil", systemImage: "person.fill") }
        }
        .tint(AppColors.pinkPrimary)
    }
}
