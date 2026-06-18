//
//  BookingRepository.swift
//  LashesLam
//
//  Espejo de data/BookingRepositoryImpl.kt. Disponibilidad de citas, horarios
//  tomados, creación de reservas y gestión de estado.
//  Estructura en Firestore:
//   - service_availability/{serviceId} → { schedule: { "yyyy-MM-dd": [{time, occupied}] } }
//   - service_reservations/{id} → ServiceReservation
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class BookingRepository {

    private var firestore: Firestore { Firestore.firestore() }
    private var auth: Auth { Auth.auth() }

    private func availabilityRef(_ serviceId: String) -> DocumentReference {
        firestore.collection("service_availability").document(serviceId)
    }
    private var reservationsRef: CollectionReference {
        firestore.collection("service_reservations")
    }

    enum Status {
        static let pending = "pendiente"
        static let scheduled = "agendado"
        static let cancelled = "cancelado"
        static let archived = "archivado"
    }
    private var activeStatuses: [String] { [Status.pending, Status.scheduled] }

    /// Disponibilidad: mapa de fecha ISO → horarios (ordenados por hora).
    func getAvailability(serviceId: String) async -> Resource<[String: [BookingSlot]]> {
        do {
            let snapshot = try await availabilityRef(serviceId).getDocument()
            let raw = snapshot.get("schedule") as? [String: Any] ?? [:]
            var schedule: [String: [BookingSlot]] = [:]
            for (date, value) in raw {
                let slots = (value as? [[String: Any]] ?? []).compactMap { entry -> BookingSlot? in
                    guard let time = entry["time"] as? String else { return nil }
                    let occupied = (entry["occupied"] as? Bool) ?? false
                    return BookingSlot(time: time, occupied: occupied)
                }.sorted { $0.time < $1.time }
                schedule[date] = slots
            }
            return .success(schedule)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    /// Horarios ya reservados (pendiente/agendado) para un servicio y fecha.
    func getTakenSlots(serviceId: String, date: String) async -> Resource<[String]> {
        do {
            let snapshot = try await reservationsRef.whereField("date", isEqualTo: date).getDocuments()
            let taken = snapshot.documents
                .map { ServiceReservation(document: $0) }
                .filter { $0.serviceId == serviceId && activeStatuses.contains($0.status) }
                .map { $0.time }
            return .success(taken)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func createReservation(_ reservation: ServiceReservation) async -> Resource<ServiceReservation> {
        do {
            guard let uid = auth.currentUser?.uid else {
                return .failure(.unknown("Sesión no válida"))
            }
            let doc = reservationsRef.document()
            let year = Calendar.current.component(.year, from: Date())
            let last4 = String(doc.documentID.suffix(4)).uppercased()

            var new = reservation
            new.reservationId = doc.documentID
            new.reservationNumber = "LL-\(year)-\(last4)"
            new.userId = uid
            new.status = Status.pending

            try await doc.setData(new.toFirestoreData())
            return .success(new)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func getReservationsByUser(userId: String) async -> Resource<[ServiceReservation]> {
        do {
            let snapshot = try await reservationsRef.whereField("userId", isEqualTo: userId).getDocuments()
            let list = snapshot.documents.map { ServiceReservation(document: $0) }
                .sorted { $0.timestamp > $1.timestamp }
            return .success(list)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func getReservationsByStatus(_ statuses: [String]) async -> Resource<[ServiceReservation]> {
        do {
            let snapshot = try await reservationsRef.whereField("status", in: statuses).getDocuments()
            let list = snapshot.documents.map { ServiceReservation(document: $0) }
                .sorted { $0.timestamp > $1.timestamp }
            return .success(list)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func updateStatus(reservationId: String, status: String) async -> Resource<Bool> {
        do {
            try await reservationsRef.document(reservationId).updateData(["status": status])
            return .success(true)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }
}
