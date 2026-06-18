//
//  ProductFormView.swift
//  LashesLam
//
//  Formulario para crear o editar un producto (admin), con imágenes y categoría.
//

import SwiftUI
import PhotosUI

struct ProductFormView: View {
    @StateObject private var viewModel: ProductFormViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var pickerItems: [PhotosPickerItem] = []

    /// onSaved se llama tras guardar para refrescar la lista de origen.
    var onSaved: () -> Void = {}

    init(product: ProductItem? = nil, onSaved: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: ProductFormViewModel(product: product))
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Imágenes") { imagesSection }

                Section("Información") {
                    TextField("Título", text: $viewModel.title)
                    TextField("Características", text: $viewModel.characteristics, axis: .vertical)
                    TextField("Descripción", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Precio") {
                    TextField("Precio actual", text: $viewModel.actualPrice).keyboardType(.decimalPad)
                    TextField("Precio anterior (opcional)", text: $viewModel.price).keyboardType(.decimalPad)
                }

                Section("Categoría") {
                    Picker("Categoría", selection: $viewModel.categoryId) {
                        Text("Selecciona…").tag("")
                        ForEach(viewModel.categories) { c in Text(c.name).tag(c.id) }
                    }
                    Toggle("Más vendido", isOn: $viewModel.bestSelling)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Editar producto" : "Nuevo producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving { ProgressView() }
                    else { Button("Guardar") { viewModel.save() }.disabled(!viewModel.isValid) }
                }
            }
            .onAppear { viewModel.loadCategories() }
            .onChange(of: pickerItems) { items in
                viewModel.addImages(items); pickerItems = []
            }
            .onChange(of: viewModel.didSave) { saved in
                if saved { onSaved(); dismiss() }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } })
            ) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: { Text(viewModel.errorMessage ?? "") }
        }
    }

    private var imagesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.remoteImages, id: \.self) { url in
                    imageThumb(remote: url)
                }
                ForEach(Array(viewModel.newImages.enumerated()), id: \.offset) { index, data in
                    imageThumb(data: data, index: index)
                }
                PhotosPicker(selection: $pickerItems, maxSelectionCount: 5, matching: .images) {
                    VStack(spacing: 4) {
                        Image(systemName: "plus").font(.title2)
                        Text("Agregar").font(.caption2)
                    }
                    .frame(width: 80, height: 80)
                    .background(AppColors.surfaceVariant)
                    .foregroundColor(AppColors.pinkPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func imageThumb(remote url: String) -> some View {
        thumbContainer {
            AsyncImage(url: URL(string: url)) { img in img.resizable().scaledToFill() } placeholder: { Color.gray.opacity(0.1) }
        } onRemove: { viewModel.removeRemoteImage(url) }
    }

    private func imageThumb(data: Data, index: Int) -> some View {
        thumbContainer {
            if let ui = UIImage(data: data) { Image(uiImage: ui).resizable().scaledToFill() } else { Color.gray.opacity(0.1) }
        } onRemove: { viewModel.removeNewImage(at: index) }
    }

    private func thumbContainer<Content: View>(@ViewBuilder content: () -> Content, onRemove: @escaping () -> Void) -> some View {
        content()
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .topTrailing) {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                .padding(4)
            }
    }
}
