//
//  CartManager.swift
//  LashesLam
//
//  Carrito en memoria (singleton observable). Espejo de data/CartRepositoryImpl.kt.
//  No se persiste: vive durante la sesión, igual que en Android.
//

import Foundation
import Combine

final class CartManager: ObservableObject {
    static let shared = CartManager()
    private init() {}

    @Published private(set) var items: [CartItem] = []

    var count: Int { items.reduce(0) { $0 + $1.quantity } }
    var subtotal: Double { items.reduce(0) { $0 + $1.price * Double($1.quantity) } }

    func addItem(_ item: CartItem) {
        if let index = items.firstIndex(where: { $0.productId == item.productId }) {
            items[index].quantity += item.quantity
        } else {
            items.append(item)
        }
    }

    func updateQuantity(productId: String, quantity: Int) {
        guard quantity > 0 else {
            removeItem(productId: productId)
            return
        }
        if let index = items.firstIndex(where: { $0.productId == productId }) {
            items[index].quantity = quantity
        }
    }

    func removeItem(productId: String) {
        items.removeAll { $0.productId == productId }
    }

    func clear() {
        items.removeAll()
    }
}
