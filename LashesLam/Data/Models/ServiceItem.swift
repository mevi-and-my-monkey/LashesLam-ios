//
//  ServiceItem.swift
//  LashesLam
//
//  Espejo de network/ServiceItem.kt + ServiceItemDto.kt. Servicio del estudio.
//

import Foundation
import FirebaseFirestore

struct ServiceItem: Identifiable, Hashable {
    let id: String
    let duration: Double
    let image: String
    let price: Double
    let title: String
    let subtitle: String
    let category: String
    let description: String
    let includes: [String]

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.id = document.documentID
        self.duration = (data["duration"] as? NSNumber)?.doubleValue ?? 0.0
        self.image = data["image"] as? String ?? ""
        self.price = (data["price"] as? NSNumber)?.doubleValue ?? 0.0
        self.title = data["title"] as? String ?? ""
        self.subtitle = data["subtitle"] as? String ?? ""
        self.category = data["category"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.includes = data["includes"] as? [String] ?? []
    }
}
