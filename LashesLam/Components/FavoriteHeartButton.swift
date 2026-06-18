//
//  FavoriteHeartButton.swift
//  LashesLam
//
//  Corazón para marcar/desmarcar favorito. Reactivo en toda la app vía
//  FavoritesManager. Se oculta para administradores (igual que Android).
//

import SwiftUI

struct FavoriteHeartButton: View {
    let itemId: String
    let type: FavoriteType
    var compact: Bool = false
    /// Sin fondo oscuro (para barras/toolbars sobre fondo claro).
    var bare: Bool = false

    @ObservedObject private var favorites = FavoritesManager.shared
    @ObservedObject private var session = SessionManager.shared

    var body: some View {
        if !session.isUserAdmin {
            Button {
                favorites.toggle(itemId: itemId, type: type)
            } label: {
                let isFav = favorites.isFavorite(itemId)
                if bare {
                    Image(systemName: isFav ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isFav ? .red : AppColors.pinkPrimary)
                } else {
                    Image(systemName: isFav ? "heart.fill" : "heart")
                        .font(.system(size: compact ? 14 : 16, weight: .semibold))
                        .foregroundColor(isFav ? .red : .white)
                        .padding(compact ? 6 : 8)
                        .background(Color.black.opacity(0.28))
                        .clipShape(Circle())
                }
            }
            .buttonStyle(.plain)
        }
    }
}
