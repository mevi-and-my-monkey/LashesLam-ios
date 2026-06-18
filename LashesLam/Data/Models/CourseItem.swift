//
//  CourseItem.swift
//  LashesLam
//
//  Espejo de network/CoursesItem.kt + CourseItemDto.kt (lista de cursos en
//  data/curse/items). costo se guarda como String y fecha como dd/MM/yyyy.
//

import Foundation
import FirebaseFirestore

struct CourseItem: Identifiable, Hashable {
    let id: String
    let titulo: String
    let imagen: String
    let costo: Double
    let fecha: String        // dd/MM/yyyy
    let horaInicio: String
    let horaFin: String

    var schedule: String { "\(horaInicio) - \(horaFin)" }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.id = document.documentID
        self.titulo = data["titulo"] as? String ?? ""
        self.imagen = data["imagen"] as? String ?? ""
        self.costo = Double(data["costo"] as? String ?? "") ?? 0.0
        self.fecha = data["fecha"] as? String ?? ""
        self.horaInicio = data["horaIncio"] as? String ?? ""  // (typo "horaIncio" tal cual en Firestore)
        self.horaFin = data["horaFin"] as? String ?? ""
    }
}
