//
//  CartViewModel.swift
//  LashesLam
//
//  Espejo de ui/cart/CartViewModel.kt. Maneja el carrito y el checkout que crea
//  la orden, limpia el carrito y abre WhatsApp.
//

import SwiftUI

@MainActor
final class CartViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var orderPlaced: ProductOrder?
    @Published var errorMessage: String?

    private let cart = CartManager.shared
    private let session = SessionManager.shared
    private let orderRepository: ProductOrderRepository

    init(orderRepository: ProductOrderRepository = ProductOrderRepository()) {
        self.orderRepository = orderRepository
    }

    var shippingCost: Double { session.shippingCost }

    func updateQuantity(productId: String, quantity: Int) {
        cart.updateQuantity(productId: productId, quantity: quantity)
    }

    func removeItem(productId: String) {
        cart.removeItem(productId: productId)
    }

    func resetOrder() {
        orderPlaced = nil
    }

    func finalizeOrder(onOpenWhatsApp: @escaping (URL) -> Void) {
        let items = cart.items
        guard !items.isEmpty, !isLoading else { return }

        Task {
            isLoading = true
            let subtotal = items.reduce(0) { $0 + $1.price * Double($1.quantity) }
            let shipping = shippingCost
            let order = ProductOrder(
                userId: session.currentUserId ?? "",
                nameUser: session.nameUser ?? "",
                emailUser: session.emailUser ?? "",
                items: items,
                subtotal: subtotal,
                shipping: shipping,
                total: subtotal + shipping
            )

            let result = await orderRepository.createOrder(order)
            isLoading = false

            switch result {
            case .success(let placed):
                cart.clear()
                orderPlaced = placed
                let whatsapp = (session.whatsApp?.isEmpty == false) ? session.whatsApp! : "5514023853"
                if let url = Formatters.whatsAppOrderURL(order: placed, whatsapp: whatsapp) {
                    onOpenWhatsApp(url)
                }
            case .failure:
                errorMessage = "No se pudo crear la orden. Intenta nuevamente."
            }
        }
    }
}
