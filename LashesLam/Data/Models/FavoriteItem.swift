//
//  FavoriteItem.swift
//  LashesLam
//
//  Espejo de network/FavoriteItem.kt + ui/favorites/FavoriteType.kt.
//  Se guarda en users/{uid}/favorites/{itemId} con { itemId, type }.
//

import Foundation

enum FavoriteType: String {
    case course = "COURSE"
    case service = "SERVICE"
    case product = "PRODUCT"
}

struct FavoriteItem: Identifiable, Hashable {
    var id: String { itemId }
    let itemId: String
    let type: String
}
