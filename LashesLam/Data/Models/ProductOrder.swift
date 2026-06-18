//
//  ProductOrder.swift
//  LashesLam
//
//  Espejo de network/ProductOrder.kt. Orden de productos guardada en
//  la colección product_orders.
//

import Foundation
import FirebaseFirestore

struct ProductOrder: Identifiable {
    var id: String { orderId }
    var orderId: String = ""
    var orderNumber: String = ""
    var userId: String = ""
    var nameUser: String = ""
    var emailUser: String = ""
    var status: String = ""
    var items: [CartItem] = []
    var subtotal: Double = 0.0
    var shipping: Double = 0.0
    var total: Double = 0.0
    var timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000)

    init() {}

    /// Init de conveniencia para crear una orden nueva antes de enviarla.
    init(userId: String, nameUser: String, emailUser: String,
         items: [CartItem], subtotal: Double, shipping: Double, total: Double) {
        self.userId = userId
        self.nameUser = nameUser
        self.emailUser = emailUser
        self.items = items
        self.subtotal = subtotal
        self.shipping = shipping
        self.total = total
    }

    /// Reconstruye la orden desde un documento de Firestore.
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.orderId = data["orderId"] as? String ?? document.documentID
        self.orderNumber = data["orderNumber"] as? String ?? ""
        self.userId = data["userId"] as? String ?? ""
        self.nameUser = data["nameUser"] as? String ?? ""
        self.emailUser = data["emailUser"] as? String ?? ""
        self.status = data["status"] as? String ?? ""
        self.items = (data["items"] as? [[String: Any]])?.map { CartItem(map: $0) } ?? []
        self.subtotal = (data["subtotal"] as? NSNumber)?.doubleValue ?? 0.0
        self.shipping = (data["shipping"] as? NSNumber)?.doubleValue ?? 0.0
        self.total = (data["total"] as? NSNumber)?.doubleValue ?? 0.0
        self.timestamp = (data["timestamp"] as? NSNumber)?.int64Value ?? 0
    }

    /// Fecha legible (timestamp en milisegundos).
    var date: Date { Date(timeIntervalSince1970: Double(timestamp) / 1000) }

    func toFirestoreData() -> [String: Any] {
        [
            "orderId": orderId,
            "orderNumber": orderNumber,
            "userId": userId,
            "nameUser": nameUser,
            "emailUser": emailUser,
            "status": status,
            "items": items.map { $0.toFirestoreData() },
            "subtotal": subtotal,
            "shipping": shipping,
            "total": total,
            "timestamp": timestamp
        ]
    }
}
