//
//  CartItem.swift
//  LashesLam
//
//  Espejo de network/CartItem.kt. Ítem del carrito (en memoria).
//

import Foundation

struct CartItem: Identifiable, Hashable {
    var id: String { productId }
    let productId: String
    let title: String
    let category: String
    let imageUrl: String
    let price: Double
    var quantity: Int

    init(productId: String, title: String, category: String, imageUrl: String, price: Double, quantity: Int) {
        self.productId = productId
        self.title = title
        self.category = category
        self.imageUrl = imageUrl
        self.price = price
        self.quantity = quantity
    }

    /// Reconstruye el ítem desde el mapa guardado en la orden de Firestore.
    init(map: [String: Any]) {
        self.productId = map["productId"] as? String ?? ""
        self.title = map["title"] as? String ?? ""
        self.category = map["category"] as? String ?? ""
        self.imageUrl = map["imageUrl"] as? String ?? ""
        self.price = (map["price"] as? NSNumber)?.doubleValue ?? 0.0
        self.quantity = (map["quantity"] as? NSNumber)?.intValue ?? 1
    }

    /// Mapa para serializar dentro de la orden en Firestore (mismos campos que Android).
    func toFirestoreData() -> [String: Any] {
        [
            "productId": productId,
            "title": title,
            "category": category,
            "imageUrl": imageUrl,
            "price": price,
            "quantity": quantity
        ]
    }
}
