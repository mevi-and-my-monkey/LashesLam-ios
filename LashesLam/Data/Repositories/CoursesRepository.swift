//
//  CoursesRepository.swift
//  LashesLam
//
//  Lado consumidor de data/CoursesRepositoryImpl.kt. Lee cursos (data/curse/items),
//  el detalle, el estado de inscripción del usuario y crea solicitudes.
//

import Foundation
import FirebaseFirestore

final class CoursesRepository {

    private var firestore: Firestore { Firestore.firestore() }

    /// Estados de inscripción (Constants.Course de Android).
    enum CourseStatus {
        static let pending = "pendiente"
        static let accepted = "aceptado"
        static let rejected = "rechazado"
        static let requested = "solicitar"   // aún no solicitado
    }

    /// Colección de cursos: data/curse/items
    private var coursesCollection: CollectionReference {
        firestore
            .collection(FirestorePaths.Courses.collection)         // "data"
            .document(FirestorePaths.Courses.document)             // "curse"
            .collection(FirestorePaths.Courses.collectionItems)    // "items"
    }

    func fetchCourses() async -> Resource<[CourseItem]> {
        do {
            let snapshot = try await coursesCollection.getDocuments()
            return .success(snapshot.documents.compactMap { CourseItem(document: $0) })
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    /// Cursos por IDs (para favoritos), en lotes de 10.
    func getCoursesByIds(_ ids: [String]) async -> Resource<[CourseItem]> {
        guard !ids.isEmpty else { return .success([]) }
        do {
            var result: [CourseItem] = []
            for chunk in ids.chunkedInTens() {
                let snapshot = try await coursesCollection
                    .whereField(FieldPath.documentID(), in: chunk).getDocuments()
                result += snapshot.documents.compactMap { CourseItem(document: $0) }
            }
            return .success(result)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func getCourseById(_ courseId: String) async -> Resource<CourseDetail> {
        do {
            let snapshot = try await coursesCollection.document(courseId).getDocument()
            guard snapshot.exists else { return .failure(.unknown("Curso no encontrado")) }
            return .success(CourseDetail(document: snapshot))
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    /// Inscripciones/solicitudes del usuario (users/{uid}/cursos).
    func getUserCourseRequests(userId: String) async -> Resource<[CourseRequest]> {
        do {
            let snapshot = try await firestore
                .collection(FirestorePaths.Users.collection)
                .document(userId)
                .collection(FirestorePaths.Users.course)
                .getDocuments()
            let list = snapshot.documents.map { CourseRequest(document: $0) }
                .sorted { $0.timestamp > $1.timestamp }
            return .success(list)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    /// Estado de inscripción del usuario para un curso (users/{uid}/cursos/{courseId}).
    func getUserCourseStatus(userId: String, courseId: String) async -> String {
        let doc = try? await firestore
            .collection(FirestorePaths.Users.collection)
            .document(userId)
            .collection(FirestorePaths.Users.course)   // "cursos"
            .document(courseId)
            .getDocument()
        return (doc?.get("status") as? String) ?? CourseStatus.requested
    }

    /// Crea la solicitud de inscripción: escribe en course_requests y en users/{uid}/cursos/{courseId}.
    func createCourseRequest(course: CourseDetail, userId: String, userName: String, userEmail: String) async -> Resource<Bool> {
        do {
            let requestRef = firestore.collection("course_requests").document()
            let dto: [String: Any] = [
                "requestId": requestRef.documentID,
                "userId": userId,
                "nameUser": userName,
                "emailUser": userEmail,
                "courseId": course.id,
                "courseName": course.titulo,
                "status": CourseStatus.pending,
                "date": course.fecha,
                "schedule": course.schedule,
                "timestamp": Int64(Date().timeIntervalSince1970 * 1000),
                "price": course.costo,
                "location": course.ubicacionNombre ?? "",
                "apartar": course.apartar
            ]
            try await requestRef.setData(dto)

            try await firestore
                .collection(FirestorePaths.Users.collection)
                .document(userId)
                .collection(FirestorePaths.Users.course)
                .document(course.id)
                .setData(dto)

            return .success(true)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }
}
