//
//  CourseFormView.swift
//  LashesLam
//
//  Formulario para crear o editar un curso (admin).
//

import SwiftUI
import PhotosUI

struct CourseFormView: View {
    @StateObject private var viewModel: CourseFormViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var coursePickerItem: PhotosPickerItem?
    @State private var instructorPickerItem: PhotosPickerItem?

    init(course: CourseDetail? = nil) {
        _viewModel = StateObject(wrappedValue: CourseFormViewModel(course: course))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Imagen del curso") {
                    imagePicker(data: viewModel.courseImage, url: viewModel.currentImageUrl,
                                selection: $coursePickerItem)
                }
                Section("Información") {
                    TextField("Título", text: $viewModel.titulo)
                    TextField("Descripción", text: $viewModel.descripcion, axis: .vertical).lineLimit(3...6)
                }
                Section("Fecha y horario") {
                    DatePicker("Fecha", selection: $viewModel.fecha, displayedComponents: .date)
                    DatePicker("Hora inicio", selection: $viewModel.horaInicio, displayedComponents: .hourAndMinute)
                    DatePicker("Hora fin", selection: $viewModel.horaFin, displayedComponents: .hourAndMinute)
                }
                Section("Costo") {
                    TextField("Costo total", text: $viewModel.costo).keyboardType(.decimalPad)
                    TextField("Apartado (opcional)", text: $viewModel.apartar).keyboardType(.decimalPad)
                }
                Section("Ubicación") {
                    Picker("Sucursal", selection: $viewModel.selectedLocationName) {
                        Text("Sin ubicación").tag("")
                        ForEach(viewModel.locations) { loc in Text(loc.name).tag(loc.name) }
                    }
                }
                Section("Temario") {
                    ForEach(viewModel.temarios.indices, id: \.self) { i in
                        HStack {
                            TextField("Tema", text: $viewModel.temarios[i])
                            Button { viewModel.removeTema(at: i) } label: {
                                Image(systemName: "minus.circle.fill").foregroundColor(.red)
                            }
                        }
                    }
                    Button { viewModel.addTema() } label: { Label("Agregar tema", systemImage: "plus.circle") }
                }
                Section("Instructora") {
                    TextField("Nombre", text: $viewModel.instructora)
                    TextField("Descripción", text: $viewModel.instructoraDesc, axis: .vertical).lineLimit(2...4)
                    imagePicker(data: viewModel.instructorImage, url: viewModel.currentInstructorImageUrl,
                                selection: $instructorPickerItem)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Editar curso" : "Nuevo curso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving { ProgressView() }
                    else { Button("Guardar") { viewModel.save() }.disabled(!viewModel.isValid) }
                }
            }
            .onAppear { viewModel.loadLocations() }
            .onChange(of: coursePickerItem) { viewModel.setCourseImage($0) }
            .onChange(of: instructorPickerItem) { viewModel.setInstructorImage($0) }
            .onChange(of: viewModel.didSave) { if $0 { dismiss() } }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } })
            ) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: { Text(viewModel.errorMessage ?? "") }
        }
    }

    private func imagePicker(data: Data?, url: String, selection: Binding<PhotosPickerItem?>) -> some View {
        HStack {
            Group {
                if let data, let ui = UIImage(data: data) {
                    Image(uiImage: ui).resizable().scaledToFill()
                } else if !url.isEmpty {
                    AsyncImage(url: URL(string: url)) { img in img.resizable().scaledToFill() } placeholder: { Color.gray.opacity(0.1) }
                } else {
                    ZStack { AppColors.surfaceVariant; Image(systemName: "photo").foregroundColor(.gray) }
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            PhotosPicker(selection: selection, matching: .images) {
                Label(data == nil && url.isEmpty ? "Elegir imagen" : "Cambiar imagen", systemImage: "photo.on.rectangle")
            }
        }
    }
}
