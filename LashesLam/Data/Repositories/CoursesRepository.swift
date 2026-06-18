//
//  CoursesRepository.swift
//  LashesLam
//
//  Lado consumidor de data/CoursesRepositoryImpl.kt. Lee cursos (data/curse/items),
//  el detalle, el estado de inscripción del usuario y crea solicitudes.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

final class CoursesRepository {

    private var firestore: Firestore { Firestore.firestore() }
    private var storage: Storage { Storage.storage() }

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

    // MARK: - Admin: crear / editar / eliminar (espejo de CoursesRepositoryImpl)

    struct CourseForm {
        var id: String = ""
        var titulo: String
        var descripcion: String
        var fecha: String        // dd/MM/yyyy
        var horaInicio: String   // HH:mm
        var horaFin: String      // HH:mm
        var costo: String
        var apartar: String
        var instructora: String
        var instructoraDesc: String
        var temarios: [String]
        var ubicacionNombre: String?
        var lat: Double?
        var lng: Double?
        var newCourseImage: Data?
        var newInstructorImage: Data?
        var currentImageUrl: String = ""
        var currentInstructorImageUrl: String = ""
    }

    func createCourse(_ form: CourseForm) async -> Resource<Void> {
        do {
            let id = UUID().uuidString
            let courseUrl = try await uploadImage(form.newCourseImage, path: "courses/\(id)/course.jpg") ?? ""
            let instructorUrl = try await uploadImage(form.newInstructorImage, path: "courses/\(id)/instructor.jpg") ?? ""
            try await coursesCollection.document(id).setData(dto(form, id: id, image: courseUrl, instructorImage: instructorUrl))
            return .success(())
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func updateCourse(_ form: CourseForm) async -> Resource<Void> {
        do {
            let courseUrl = try await uploadImage(form.newCourseImage, path: "courses/\(form.id)/course.jpg") ?? form.currentImageUrl
            let instructorUrl = try await uploadImage(form.newInstructorImage, path: "courses/\(form.id)/instructor.jpg") ?? form.currentInstructorImageUrl
            try await coursesCollection.document(form.id).setData(dto(form, id: form.id, image: courseUrl, instructorImage: instructorUrl))
            return .success(())
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func deleteCourse(id: String, imageUrl: String) async -> Resource<Void> {
        do {
            if !imageUrl.isEmpty { try? await storage.reference(forURL: imageUrl).delete() }
            try await coursesCollection.document(id).delete()
            return .success(())
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    private func dto(_ form: CourseForm, id: String, image: String, instructorImage: String) -> [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "titulo": form.titulo,
            "descripcion": form.descripcion,
            "horaIncio": form.horaInicio,   // clave con el typo tal cual está en Firestore
            "horaFin": form.horaFin,
            "fecha": form.fecha,
            "costo": form.costo,
            "apartar": form.apartar,
            "instructora": form.instructora,
            "instructoraDesc": form.instructoraDesc,
            "temarios": form.temarios,
            "imagen": image,
            "instructoraImage": instructorImage,
            "banner": 0
        ]
        if let name = form.ubicacionNombre { data["ubicacionNombre"] = name }
        if let lat = form.lat { data["lat"] = lat }
        if let lng = form.lng { data["lng"] = lng }
        return data
    }

    private func uploadImage(_ data: Data?, path: String) async throws -> String? {
        guard let data else { return nil }
        let ref = storage.reference().child(path)
        _ = try await ref.putDataAsync(data)
        return try await ref.downloadURL().absoluteString
    }
}
