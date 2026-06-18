//
//  CourseRequestRepository.swift
//  LashesLam
//
//  Espejo de data/CourseRequestRepositoryImpl.kt (lado admin). Lista solicitudes
//  por estado y aprueba/rechaza con escritura por lotes en varias colecciones.
//

import Foundation
import FirebaseFirestore

final class CourseRequestRepository {

    private var firestore: Firestore { Firestore.firestore() }
    private var requestsRef: CollectionReference { firestore.collection("course_requests") }

    func getRequestsByStatus(_ status: String) async -> Resource<[CourseRequest]> {
        do {
            let snapshot = try await requestsRef.whereField("status", isEqualTo: status).getDocuments()
            let list = snapshot.documents.map { CourseRequest(document: $0) }
                .sorted { $0.timestamp > $1.timestamp }
            return .success(list)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    /// Aprueba: inscribe al alumno y elimina la solicitud (batch), igual que Android.
    func approveRequest(_ requestId: String) async -> Resource<Bool> {
        do {
            let requestRef = requestsRef.document(requestId)
            let snapshot = try await requestRef.getDocument()
            guard let data = snapshot.data(),
                  let userId = data["userId"] as? String,
                  let courseId = data["courseId"] as? String else {
                return .failure(.unknown("Solicitud no encontrada"))
            }

            let userCourseRef = firestore
                .collection(FirestorePaths.Users.collection).document(userId)
                .collection(FirestorePaths.Users.course).document(courseId)

            let courseParentRef = firestore
                .collection("alumnos_inscritos").document(courseId)
            let enrolledRef = courseParentRef.collection("inscritos").document(requestId)

            let cursoData: [String: Any] = [
                "courseId": courseId,
                "courseName": data["courseName"] as? String ?? "",
                "date": data["date"] as? String ?? "",
                "schedule": data["schedule"] as? String ?? "",
                "status": CoursesRepository.CourseStatus.accepted,
                "requestId": requestId,
                "notification": "notCreated",
                "timestamp": data["timestamp"] ?? Int64(Date().timeIntervalSince1970 * 1000),
                "price": data["price"] as? String ?? "",
                "location": data["location"] as? String ?? "",
                "apartar": data["apartar"] as? String ?? ""
            ]

            let batch = firestore.batch()
            batch.setData(cursoData, forDocument: userCourseRef)
            batch.setData(["courseId": courseId], forDocument: courseParentRef)
            batch.setData(data, forDocument: enrolledRef)
            batch.deleteDocument(requestRef)
            try await batch.commit()

            return .success(true)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    /// Rechaza: elimina la solicitud y devuelve el estado del usuario a "solicitar".
    func rejectRequest(_ requestId: String) async -> Resource<Bool> {
        do {
            let requestRef = requestsRef.document(requestId)
            let snapshot = try await requestRef.getDocument()
            guard let data = snapshot.data(),
                  let userId = data["userId"] as? String,
                  let courseId = data["courseId"] as? String else {
                return .failure(.unknown("Solicitud no encontrada"))
            }

            let userCourseRef = firestore
                .collection(FirestorePaths.Users.collection).document(userId)
                .collection(FirestorePaths.Users.course).document(courseId)

            let batch = firestore.batch()
            batch.deleteDocument(requestRef)
            batch.updateData(["status": CoursesRepository.CourseStatus.requested], forDocument: userCourseRef)
            try await batch.commit()

            return .success(true)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }
}
