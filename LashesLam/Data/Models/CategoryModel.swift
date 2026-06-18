//
//  CategoryModel.swift
//  LashesLam
//
//  Espejo de network/CategoryModel.kt.
//

import Foundation
import FirebaseFirestore

struct CategoryModel: Identifiable, Hashable {
    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.id = document.documentID
        self.name = data["name"] as? String ?? ""
    }

    /// Categoría sintética "Todos" para limpiar el filtro (id = "all", igual que CATEGORY_ALL).
    static let all = CategoryModel(id: "all", name: "Todos")
}
