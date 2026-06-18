//
//  ServicesRepository.swift
//  LashesLam
//
//  Lado consumidor de data/ServicesRepositoryImpl.kt. Lee servicios y categorías
//  desde data/service/services y data/service/categories.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

final class ServicesRepository {

    private var firestore: Firestore { Firestore.firestore() }
    private var storage: Storage { Storage.storage() }

    private var servicesCollection: CollectionReference {
        firestore
            .collection(FirestorePaths.Courses.collection)            // "data"
            .document(FirestorePaths.Services.document)               // "service"
            .collection(FirestorePaths.Services.collectionServicesItems) // "services"
    }

    private var categoriesCollection: CollectionReference {
        firestore
            .collection(FirestorePaths.Courses.collection)            // "data"
            .document(FirestorePaths.Services.document)               // "service"
            .collection("categories")
    }

    func fetchServices() async -> Resource<[ServiceItem]> {
        do {
            let snapshot = try await servicesCollection.getDocuments()
            return .success(snapshot.documents.compactMap { ServiceItem(document: $0) })
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    /// Servicios por IDs (para favoritos), en lotes de 10.
    func getServicesByIds(_ ids: [String]) async -> Resource<[ServiceItem]> {
        guard !ids.isEmpty else { return .success([]) }
        do {
            var result: [ServiceItem] = []
            for chunk in ids.chunkedInTens() {
                let snapshot = try await servicesCollection
                    .whereField(FieldPath.documentID(), in: chunk).getDocuments()
                result += snapshot.documents.compactMap { ServiceItem(document: $0) }
            }
            return .success(result)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func fetchCategories() async -> Resource<[CategoryModel]> {
        do {
            let snapshot = try await categoriesCollection.getDocuments()
            return .success(snapshot.documents.compactMap { CategoryModel(document: $0) })
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    // MARK: - Admin: crear / editar / eliminar (espejo de ServicesRepositoryImpl)

    struct ServiceForm {
        var id: String = ""
        var title: String
        var subtitle: String
        var duration: Double
        var price: Double
        var category: String
        var description: String
        var includes: [String]
        var newImage: Data?         // imagen nueva a subir
        var currentImageUrl: String // imagen actual (edición)
    }

    func createService(_ form: ServiceForm) async -> Resource<Void> {
        do {
            let id = UUID().uuidString
            let imageUrl = try await uploadServiceImage(serviceId: id, image: form.newImage) ?? ""
            try await servicesCollection.document(id).setData(dto(form, id: id, image: imageUrl))
            return .success(())
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func updateService(_ form: ServiceForm) async -> Resource<Void> {
        do {
            let imageUrl = try await uploadServiceImage(serviceId: form.id, image: form.newImage) ?? form.currentImageUrl
            try await servicesCollection.document(form.id).setData(dto(form, id: form.id, image: imageUrl))
            return .success(())
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func deleteService(id: String, imageUrl: String) async -> Resource<Void> {
        do {
            if !imageUrl.isEmpty { try? await storage.reference(forURL: imageUrl).delete() }
            try await servicesCollection.document(id).delete()
            return .success(())
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    private func dto(_ form: ServiceForm, id: String, image: String) -> [String: Any] {
        [
            "id": id,
            "duration": form.duration,
            "category": form.category,
            "subtitle": form.subtitle,
            "price": form.price,
            "title": form.title,
            "image": image,
            "description": form.description,
            "includes": form.includes
        ]
    }

    /// Sube la imagen a services/{id}/service.jpg y devuelve su URL (o nil si no hay).
    private func uploadServiceImage(serviceId: String, image: Data?) async throws -> String? {
        guard let image else { return nil }
        let ref = storage.reference().child("services/\(serviceId)/service.jpg")
        _ = try await ref.putDataAsync(image)
        return try await ref.downloadURL().absoluteString
    }
}
