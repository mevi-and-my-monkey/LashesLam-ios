//
//  FirestorePaths.swift
//  LashesLam
//
//  Réplica EXACTA de data/constants/FirestorePaths.kt para mantener compatibilidad
//  con los documentos que crea/lee la app de Android (mismo backend lasheslam-ed6cf).
//

import Foundation

enum FirestorePaths {

    enum Users {
        static let collection = "users"
        static let userId = "userId"
        static let course = "cursos"
        static let userPhoto = "userPhoto"
        static let userName = "name"
        static let photoUpdatedByUser = "photoUpdatedByUser"

        static func document(_ userId: String) -> String { "\(collection)/\(userId)" }
    }

    enum Courses {
        static let collection = "data"
        static let document = "curse"
        static let collectionItems = "items"
        static func collectionPath() -> String { "\(collection)/\(document)/\(collectionItems)" }
    }

    enum Products {
        static let document = "stock"
        static let collectionProductsItems = "products"
        static func collectionPath() -> String { "\(Courses.collection)/\(document)/\(collectionProductsItems)" }
    }

    enum Services {
        static let document = "service"
        static let collectionServicesItems = "services"
        static func collectionPath() -> String { "\(Courses.collection)/\(document)/\(collectionServicesItems)" }
    }
}
