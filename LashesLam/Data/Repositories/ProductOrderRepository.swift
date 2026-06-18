//
//  ProductOrderRepository.swift
//  LashesLam
//
//  Espejo de data/ProductOrderRepositoryImpl.kt (createOrder). Crea la orden en
//  la colección product_orders con número LL-{año}-{últimos4} y estado "pendiente".
//

import Foundation
import FirebaseFirestore

final class ProductOrderRepository {

    private var ordersRef: CollectionReference {
        Firestore.firestore().collection("product_orders")
    }

    enum Status {
        static let pending = "pendiente"
        static let completed = "finalizado"
        static let archived = "archivado"
        static let legacyAccepted = "aceptado"
    }

    func createOrder(_ order: ProductOrder) async -> Resource<ProductOrder> {
        do {
            let doc = ordersRef.document()
            let year = Calendar.current.component(.year, from: Date())
            let last4 = String(doc.documentID.suffix(4)).uppercased()

            var newOrder = order
            newOrder.orderId = doc.documentID
            newOrder.orderNumber = "LL-\(year)-\(last4)"
            newOrder.status = Status.pending

            try await doc.setData(newOrder.toFirestoreData())
            return .success(newOrder)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    /// Órdenes del usuario actual, ordenadas por fecha desc.
    func getOrdersByUser(userId: String) async -> Resource<[ProductOrder]> {
        do {
            let snapshot = try await ordersRef.whereField("userId", isEqualTo: userId).getDocuments()
            let orders = snapshot.documents.map { ProductOrder(document: $0) }
                .sorted { $0.timestamp > $1.timestamp }
            return .success(orders)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    /// Órdenes por estado (para admin), ordenadas por fecha desc.
    func getOrdersByStatus(_ statuses: [String]) async -> Resource<[ProductOrder]> {
        do {
            let snapshot = try await ordersRef.whereField("status", in: statuses).getDocuments()
            let orders = snapshot.documents.map { ProductOrder(document: $0) }
                .sorted { $0.timestamp > $1.timestamp }
            return .success(orders)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func updateStatus(orderId: String, status: String) async -> Resource<Bool> {
        do {
            try await ordersRef.document(orderId).updateData(["status": status])
            return .success(true)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }
}
