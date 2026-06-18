//
//  ServiceReservation.swift
//  LashesLam
//
//  Espejo de network/ServiceReservation.kt + BookingAvailability.kt. Reserva de cita
//  y modelos de disponibilidad (horarios por fecha).
//

import Foundation
import FirebaseFirestore

/// Un horario ofrecido en una fecha. occupied = bloqueado por el admin.
struct BookingSlot: Hashable {
    let time: String
    let occupied: Bool
}

struct ServiceReservation: Identifiable {
    var id: String { reservationId }
    var reservationId: String = ""
    var reservationNumber: String = ""
    var serviceId: String = ""
    var serviceName: String = ""
    var durationLabel: String = ""
    var price: Double = 0.0
    var userId: String = ""
    var nameUser: String = ""
    var emailUser: String = ""
    var date: String = ""        // ISO yyyy-MM-dd
    var dateLabel: String = ""   // "Vie 19 Jun"
    var time: String = ""        // HH:mm
    var status: String = ""
    var timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000)

    init() {}

    init(serviceId: String, serviceName: String, durationLabel: String, price: Double,
         userId: String, nameUser: String, emailUser: String,
         date: String, dateLabel: String, time: String) {
        self.serviceId = serviceId
        self.serviceName = serviceName
        self.durationLabel = durationLabel
        self.price = price
        self.userId = userId
        self.nameUser = nameUser
        self.emailUser = emailUser
        self.date = date
        self.dateLabel = dateLabel
        self.time = time
    }

    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.reservationId = data["reservationId"] as? String ?? document.documentID
        self.reservationNumber = data["reservationNumber"] as? String ?? ""
        self.serviceId = data["serviceId"] as? String ?? ""
        self.serviceName = data["serviceName"] as? String ?? ""
        self.durationLabel = data["durationLabel"] as? String ?? ""
        self.price = (data["price"] as? NSNumber)?.doubleValue ?? 0.0
        self.userId = data["userId"] as? String ?? ""
        self.nameUser = data["nameUser"] as? String ?? ""
        self.emailUser = data["emailUser"] as? String ?? ""
        self.date = data["date"] as? String ?? ""
        self.dateLabel = data["dateLabel"] as? String ?? ""
        self.time = data["time"] as? String ?? ""
        self.status = data["status"] as? String ?? ""
        self.timestamp = (data["timestamp"] as? NSNumber)?.int64Value ?? 0
    }

    func toFirestoreData() -> [String: Any] {
        [
            "reservationId": reservationId,
            "reservationNumber": reservationNumber,
            "serviceId": serviceId,
            "serviceName": serviceName,
            "durationLabel": durationLabel,
            "price": price,
            "userId": userId,
            "nameUser": nameUser,
            "emailUser": emailUser,
            "date": date,
            "dateLabel": dateLabel,
            "time": time,
            "status": status,
            "timestamp": timestamp
        ]
    }
}
