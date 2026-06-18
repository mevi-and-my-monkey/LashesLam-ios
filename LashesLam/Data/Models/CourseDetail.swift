//
//  CourseDetail.swift
//  LashesLam
//
//  Espejo de network/CreateCourseDto.kt. Detalle completo del curso.
//

import Foundation
import FirebaseFirestore

struct CourseDetail {
    var id: String = ""
    var titulo: String = ""
    var descripcion: String = ""
    var horaInicio: String = ""
    var horaFin: String = ""
    var fecha: String = ""
    var costo: String = ""
    var apartar: String = ""
    var instructora: String = ""
    var instructoraDesc: String = ""
    var temarios: [String] = []
    var imagen: String = ""
    var instructoraImage: String = ""
    var ubicacionNombre: String?
    var lat: Double?
    var lng: Double?

    init(document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        self.id = data["id"] as? String ?? document.documentID
        self.titulo = data["titulo"] as? String ?? ""
        self.descripcion = data["descripcion"] as? String ?? ""
        self.horaInicio = data["horaIncio"] as? String ?? ""
        self.horaFin = data["horaFin"] as? String ?? ""
        self.fecha = data["fecha"] as? String ?? ""
        self.costo = data["costo"] as? String ?? ""
        self.apartar = data["apartar"] as? String ?? ""
        self.instructora = data["instructora"] as? String ?? ""
        self.instructoraDesc = data["instructoraDesc"] as? String ?? ""
        self.temarios = data["temarios"] as? [String] ?? []
        self.imagen = data["imagen"] as? String ?? ""
        self.instructoraImage = data["instructoraImage"] as? String ?? ""
        self.ubicacionNombre = data["ubicacionNombre"] as? String
        self.lat = (data["lat"] as? NSNumber)?.doubleValue
        self.lng = (data["lng"] as? NSNumber)?.doubleValue
    }

    var schedule: String { "\(horaInicio) - \(horaFin)" }
    var priceValue: Double { Double(costo) ?? 0 }
}
