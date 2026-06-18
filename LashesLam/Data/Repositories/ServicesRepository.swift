//
//  ServicesRepository.swift
//  LashesLam
//
//  Lado consumidor de data/ServicesRepositoryImpl.kt. Lee servicios y categorías
//  desde data/service/services y data/service/categories.
//

import Foundation
import FirebaseFirestore

final class ServicesRepository {

    private var firestore: Firestore { Firestore.firestore() }

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
}
