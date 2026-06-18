//
//  FavoritesManager.swift
//  LashesLam
//
//  Estado global de favoritos para que el corazón reaccione en toda la app.
//  Escribe en Firestore y mantiene el set local sincronizado (optimista).
//

import Foundation
import Combine

@MainActor
final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    private init() {}

    /// Conjunto de itemIds marcados como favoritos.
    @Published private(set) var favoriteIds: Set<String> = []
    /// Lista completa (con tipo) para resolver la pantalla de favoritos.
    @Published private(set) var favorites: [FavoriteItem] = []

    private let repository = FavoritesRepository()
    private let session = SessionManager.shared

    func isFavorite(_ itemId: String) -> Bool { favoriteIds.contains(itemId) }

    func load() {
        guard let userId = session.currentUserId, !userId.isEmpty else { return }
        Task {
            if case .success(let items) = await repository.getFavorites(userId: userId) {
                favorites = items
                favoriteIds = Set(items.map { $0.itemId })
            }
        }
    }

    func clear() {
        favorites = []
        favoriteIds = []
    }

    func toggle(itemId: String, type: FavoriteType) {
        guard let userId = session.currentUserId, !userId.isEmpty else { return }
        let wasFavorite = favoriteIds.contains(itemId)

        // Actualización optimista.
        if wasFavorite {
            favoriteIds.remove(itemId)
            favorites.removeAll { $0.itemId == itemId }
        } else {
            favoriteIds.insert(itemId)
            favorites.append(FavoriteItem(itemId: itemId, type: type.rawValue))
        }

        Task {
            let result = wasFavorite
                ? await repository.remove(userId: userId, itemId: itemId)
                : await repository.add(userId: userId, itemId: itemId, type: type.rawValue)

            // Si falla, revierte.
            if case .failure = result {
                if wasFavorite {
                    favoriteIds.insert(itemId)
                    favorites.append(FavoriteItem(itemId: itemId, type: type.rawValue))
                } else {
                    favoriteIds.remove(itemId)
                    favorites.removeAll { $0.itemId == itemId }
                }
            }
        }
    }
}
