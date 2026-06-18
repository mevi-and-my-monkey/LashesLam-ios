//
//  FavoritesRepository.swift
//  LashesLam
//
//  Espejo de data/FavoritesRepositoryImpl.kt. Favoritos en users/{uid}/favorites.
//

import Foundation
import FirebaseFirestore

final class FavoritesRepository {

    private var firestore: Firestore { Firestore.firestore() }

    private func favoritesRef(_ userId: String) -> CollectionReference {
        firestore.collection(FirestorePaths.Users.collection)
            .document(userId)
            .collection("favorites")
    }

    func add(userId: String, itemId: String, type: String) async -> Resource<Bool> {
        do {
            try await favoritesRef(userId).document(itemId)
                .setData(["itemId": itemId, "type": type])
            return .success(true)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func remove(userId: String, itemId: String) async -> Resource<Bool> {
        do {
            try await favoritesRef(userId).document(itemId).delete()
            return .success(true)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func getFavorites(userId: String) async -> Resource<[FavoriteItem]> {
        do {
            let snapshot = try await favoritesRef(userId).getDocuments()
            let items = snapshot.documents.compactMap { doc -> FavoriteItem? in
                guard let itemId = doc.get("itemId") as? String,
                      let type = doc.get("type") as? String else { return nil }
                return FavoriteItem(itemId: itemId, type: type)
            }
            return .success(items)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }
}
