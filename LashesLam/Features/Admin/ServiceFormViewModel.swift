//
//  ServiceFormViewModel.swift
//  LashesLam
//
//  Crear o editar un servicio (admin).
//

import SwiftUI
import PhotosUI

@MainActor
final class ServiceFormViewModel: ObservableObject {

    @Published var title = ""
    @Published var subtitle = ""
    @Published var duration = ""
    @Published var price = ""
    @Published var categoryId = ""
    @Published var description = ""
    @Published var includes: [String] = []

    @Published var categories: [CategoryModel] = []
    @Published var currentImageUrl = ""
    @Published var newImage: Data?

    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var didSave = false

    let isEditing: Bool
    private let editingId: String
    private let repository = ServicesRepository()

    init(service: ServiceItem? = nil) {
        if let s = service {
            isEditing = true
            editingId = s.id
            title = s.title
            subtitle = s.subtitle
            duration = String(s.duration)
            price = String(s.price)
            categoryId = s.category
            description = s.description
            includes = s.includes
            currentImageUrl = s.image
        } else {
            isEditing = false
            editingId = ""
        }
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Double(price) != nil) && (Double(duration) != nil) &&
        !categoryId.isEmpty &&
        (newImage != nil || !currentImageUrl.isEmpty)
    }

    func loadCategories() {
        Task {
            if case .success(let cats) = await repository.fetchCategories() {
                categories = cats
                if categoryId.isEmpty { categoryId = cats.first?.id ?? "" }
            }
        }
    }

    func setImage(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task { if let data = try? await item.loadTransferable(type: Data.self) { newImage = data } }
    }

    func addInclude() { includes.append("") }
    func removeInclude(at index: Int) { if includes.indices.contains(index) { includes.remove(at: index) } }

    func save() {
        guard isValid, !isSaving else { return }
        let form = ServicesRepository.ServiceForm(
            id: editingId,
            title: title.trimmingCharacters(in: .whitespaces),
            subtitle: subtitle,
            duration: Double(duration) ?? 0,
            price: Double(price) ?? 0,
            category: categoryId,
            description: description,
            includes: includes.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty },
            newImage: newImage,
            currentImageUrl: currentImageUrl
        )
        Task {
            isSaving = true
            let result = isEditing ? await repository.updateService(form)
                                   : await repository.createService(form)
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
