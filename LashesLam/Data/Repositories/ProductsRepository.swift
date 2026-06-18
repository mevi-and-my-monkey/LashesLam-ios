//
//  ProductsRepository.swift
//  LashesLam
//
//  Espejo (lado consumidor) de data/ProductsRepositoryImpl.kt. Lee productos y
//  categorías desde el mismo backend que Android: data/stock/products y
//  data/stock/categories.
//

import Foundation
import FirebaseFirestore

final class ProductsRepository {

    private var firestore: Firestore { Firestore.firestore() }

    /// Colección de productos: data/stock/products
    private var productsCollection: CollectionReference {
        firestore
            .collection(FirestorePaths.Courses.collection)        // "data"
            .document(FirestorePaths.Products.document)            // "stock"
            .collection(FirestorePaths.Products.collectionProductsItems) // "products"
    }

    /// Colección de categorías: data/stock/categories
    private var categoriesCollection: CollectionReference {
        firestore
            .collection(FirestorePaths.Courses.collection)        // "data"
            .document(FirestorePaths.Products.document)            // "stock"
            .collection("categories")
    }

    func fetchProducts() async -> Resource<[ProductItem]> {
        do {
            let snapshot = try await productsCollection.getDocuments()
            let products = snapshot.documents.compactMap { ProductItem(document: $0) }
            return .success(products)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    /// Productos por IDs (para favoritos), en lotes de 10 como Android.
    func getProductsByIds(_ ids: [String]) async -> Resource<[ProductItem]> {
        guard !ids.isEmpty else { return .success([]) }
        do {
            var result: [ProductItem] = []
            for chunk in ids.chunkedInTens() {
                let snapshot = try await productsCollection
                    .whereField(FieldPath.documentID(), in: chunk).getDocuments()
                result += snapshot.documents.compactMap { ProductItem(document: $0) }
            }
            return .success(result)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func fetchCategories() async -> Resource<[CategoryModel]> {
        do {
            let snapshot = try await categoriesCollection.getDocuments()
            let categories = snapshot.documents.compactMap { CategoryModel(document: $0) }
            return .success(categories)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }
}
