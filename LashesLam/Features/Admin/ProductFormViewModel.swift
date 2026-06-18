//
//  ProductFormViewModel.swift
//  LashesLam
//
//  Crear o editar un producto (admin). Maneja campos, categorías, imágenes
//  (existentes + nuevas) y guardado.
//

import SwiftUI
import PhotosUI

@MainActor
final class ProductFormViewModel: ObservableObject {

    @Published var title = ""
    @Published var characteristics = ""
    @Published var description = ""
    @Published var price = ""
    @Published var actualPrice = ""
    @Published var categoryId = ""
    @Published var bestSelling = false

    @Published var categories: [CategoryModel] = []
    @Published var remoteImages: [String] = []   // ya subidas (edición)
    @Published var newImages: [Data] = []        // nuevas a subir

    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var didSave = false

    let isEditing: Bool
    private let editingId: String
    private let repository = ProductsRepository()

    init(product: ProductItem? = nil) {
        if let p = product {
            isEditing = true
            editingId = p.id
            title = p.title
            characteristics = p.characteristics
            description = p.description
            price = p.price == 0 ? "" : String(p.price)
            actualPrice = String(p.actualPrice)
            categoryId = p.category
            bestSelling = p.bestSelling
            remoteImages = p.images
        } else {
            isEditing = false
            editingId = ""
        }
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !actualPrice.isEmpty && (Double(actualPrice) != nil) &&
        !categoryId.isEmpty &&
        (!remoteImages.isEmpty || !newImages.isEmpty)
    }

    func loadCategories() {
        Task {
            if case .success(let cats) = await repository.fetchCategories() {
                categories = cats
                if categoryId.isEmpty { categoryId = cats.first?.id ?? "" }
            }
        }
    }

    func addImages(_ items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    newImages.append(data)
                }
            }
        }
    }

    func removeNewImage(at index: Int) {
        guard newImages.indices.contains(index) else { return }
        newImages.remove(at: index)
    }

    func removeRemoteImage(_ url: String) {
        remoteImages.removeAll { $0 == url }
    }

    func save() {
        guard isValid, !isSaving else { return }
        let form = ProductsRepository.ProductForm(
            id: editingId,
            title: title.trimmingCharacters(in: .whitespaces),
            characteristics: characteristics,
            description: description,
            price: Double(price) ?? 0,
            actualPrice: Double(actualPrice) ?? 0,
            category: categoryId,
            bestSelling: bestSelling,
            newImages: newImages,
            remoteImages: remoteImages
        )
        Task {
            isSaving = true
            let result = isEditing ? await repository.updateProduct(form)
                                   : await repository.createProduct(form)
            isSaving = false
            switch result {
            case .success:
                NotificationCenter.default.post(name: .catalogDidChange, object: nil)
                didSave = true
            case .failure(let error): errorMessage = error.userMessage
            }
        }
    }
}
