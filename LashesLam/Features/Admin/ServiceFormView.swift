//
//  ServiceFormView.swift
//  LashesLam
//
//  Formulario para crear o editar un servicio (admin).
//

import SwiftUI
import PhotosUI

struct ServiceFormView: View {
    @StateObject private var viewModel: ServiceFormViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var pickerItem: PhotosPickerItem?

    init(service: ServiceItem? = nil) {
        _viewModel = StateObject(wrappedValue: ServiceFormViewModel(service: service))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Imagen") { imageSection }

                Section("Información") {
                    TextField("Título", text: $viewModel.title)
                    TextField("Subtítulo", text: $viewModel.subtitle)
                    TextField("Descripción", text: $viewModel.description, axis: .vertical).lineLimit(3...6)
                }

                Section("Detalles") {
                    TextField("Precio", text: $viewModel.price).keyboardType(.decimalPad)
                    TextField("Duración (horas, ej. 1.5)", text: $viewModel.duration).keyboardType(.decimalPad)
                    Picker("Categoría", selection: $viewModel.categoryId) {
                        Text("Selecciona…").tag("")
                        ForEach(viewModel.categories) { c in Text(c.name).tag(c.id) }
                    }
                }

                Section("Incluye") {
                    ForEach(viewModel.includes.indices, id: \.self) { i in
                        HStack {
                            TextField("Elemento", text: $viewModel.includes[i])
                            Button { viewModel.removeInclude(at: i) } label: {
                                Image(systemName: "minus.circle.fill").foregroundColor(.red)
                            }
                        }
                    }
                    Button { viewModel.addInclude() } label: {
                        Label("Agregar elemento", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "Editar servicio" : "Nuevo servicio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving { ProgressView() }
                    else { Button("Guardar") { viewModel.save() }.disabled(!viewModel.isValid) }
                }
            }
            .onAppear { viewModel.loadCategories() }
            .onChange(of: pickerItem) { item in viewModel.setImage(item) }
            .onChange(of: viewModel.didSave) { if $0 { dismiss() } }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } })
            ) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: { Text(viewModel.errorMessage ?? "") }
        }
    }

    private var imageSection: some View {
        HStack {
            Group {
                if let data = viewModel.newImage, let ui = UIImage(data: data) {
                    Image(uiImage: ui).resizable().scaledToFill()
                } else if !viewModel.currentImageUrl.isEmpty {
                    AsyncImage(url: URL(string: viewModel.currentImageUrl)) { img in img.resizable().scaledToFill() } placeholder: { Color.gray.opacity(0.1) }
                } else {
                    ZStack { AppColors.surfaceVariant; Image(systemName: "photo").foregroundColor(.gray) }
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            PhotosPicker(selection: $pickerItem, matching: .images) {
                Label(viewModel.currentImageUrl.isEmpty && viewModel.newImage == nil ? "Elegir imagen" : "Cambiar imagen",
                      systemImage: "photo.on.rectangle")
            }
        }
    }
}
