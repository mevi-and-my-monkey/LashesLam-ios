//
//  ProductItem.swift
//  LashesLam
//
//  Espejo de network/ProductItem.kt + ProductItemDto.kt. Producto de la tienda.
//  Las claves en Firestore usan snake_case (actual_price, best_selling).
//

import Foundation
import FirebaseFirestore

struct ProductItem: Identifiable, Hashable {
    let id: String
    let actualPrice: Double
    let bestSelling: Bool
    let category: String
    let description: String
    let characteristics: String
    let images: [String]
    let title: String
    let price: Double

    /// Crea el producto a partir del documento de Firestore (mismo esquema que Android).
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.id = document.documentID
        self.actualPrice = (data["actual_price"] as? NSNumber)?.doubleValue ?? 0.0
        self.bestSelling = (data["best_selling"] as? Bool) ?? false
        self.category = data["category"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.characteristics = data["characteristics"] as? String ?? ""
        self.images = data["images"] as? [String] ?? []
        self.title = data["title"] as? String ?? ""
        self.price = (data["price"] as? NSNumber)?.doubleValue ?? 0.0
    }
}
