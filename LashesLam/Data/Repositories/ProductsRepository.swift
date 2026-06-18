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
import FirebaseStorage

final class ProductsRepository {

    private var firestore: Firestore { Firestore.firestore() }
    private var storage: Storage { Storage.storage() }

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

    // MARK: - Admin: crear / editar / eliminar (espejo de ProductsRepositoryImpl)

    struct ProductForm {
        var id: String = ""
        var title: String
        var characteristics: String
        var description: String
        var price: Double
        var actualPrice: Double
        var category: String
        var bestSelling: Bool
        var newImages: [Data] = []        // imágenes nuevas a subir
        var remoteImages: [String] = []   // URLs ya existentes (edición)
    }

    func createProduct(_ form: ProductForm) async -> Resource<Void> {
        do {
            let id = UUID().uuidString
            let urls = try await uploadImages(productId: id, images: form.newImages, startIndex: 0)
            try await productsCollection.document(id).setData(dto(form, id: id, images: urls))
            return .success(())
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func updateProduct(_ form: ProductForm) async -> Resource<Void> {
        do {
            let newUrls = try await uploadImages(productId: form.id, images: form.newImages,
                                                 startIndex: form.remoteImages.count)
            let finalImages = form.remoteImages + newUrls
            try await productsCollection.document(form.id).setData(dto(form, id: form.id, images: finalImages))
            return .success(())
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func deleteProduct(id: String, imageUrls: [String]) async -> Resource<Void> {
        do {
            for url in imageUrls where !url.isEmpty {
                try? await storage.reference(forURL: url).delete()
            }
            try await productsCollection.document(id).delete()
            return .success(())
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    private func dto(_ form: ProductForm, id: String, images: [String]) -> [String: Any] {
        [
            "id": id,
            "actual_price": form.actualPrice,
            "best_selling": form.bestSelling,
            "category": form.category,
            "description": form.description,
            "price": form.price,
            "title": form.title,
            "characteristics": form.characteristics,
            "images": images
        ]
    }

    /// Sube imágenes a products/{id}/image_N.jpg y devuelve sus URLs.
    private func uploadImages(productId: String, images: [Data], startIndex: Int) async throws -> [String] {
        var urls: [String] = []
        for (i, data) in images.enumerated() {
            let ref = storage.reference().child("products/\(productId)/image_\(startIndex + i).jpg")
            _ = try await ref.putDataAsync(data)
            urls.append(try await ref.downloadURL().absoluteString)
        }
        return urls
    }
}
