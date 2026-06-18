//
//  CourseFormViewModel.swift
//  LashesLam
//
//  Crear o editar un curso (admin): datos, fecha/horario, ubicación (sucursal),
//  temario y dos imágenes (curso e instructora).
//

import SwiftUI
import PhotosUI

@MainActor
final class CourseFormViewModel: ObservableObject {

    @Published var titulo = ""
    @Published var descripcion = ""
    @Published var costo = ""
    @Published var apartar = ""
    @Published var instructora = ""
    @Published var instructoraDesc = ""
    @Published var fecha = Date()
    @Published var horaInicio = Date()
    @Published var horaFin = Date()
    @Published var temarios: [String] = []

    @Published var locations: [LocationItem] = []
    @Published var selectedLocationName: String = ""

    @Published var courseImage: Data?
    @Published var instructorImage: Data?
    @Published var currentImageUrl = ""
    @Published var currentInstructorImageUrl = ""

    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var didSave = false

    let isEditing: Bool
    private let editingId: String
    private let repository = CoursesRepository()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter(); f.locale = Locale(identifier: "es_MX"); f.dateFormat = "dd/MM/yyyy"; return f
    }()
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter(); f.locale = Locale(identifier: "en_US_POSIX"); f.dateFormat = "HH:mm"; return f
    }()

    init(course: CourseDetail? = nil) {
        locations = SessionManager.shared.locations
        if let c = course {
            isEditing = true
            editingId = c.id
            titulo = c.titulo
            descripcion = c.descripcion
            costo = c.costo
            apartar = c.apartar
            instructora = c.instructora
            instructoraDesc = c.instructoraDesc
            temarios = c.temarios
            currentImageUrl = c.imagen
            currentInstructorImageUrl = c.instructoraImage
            selectedLocationName = c.ubicacionNombre ?? ""
            if let d = Self.dateFormatter.date(from: c.fecha) { fecha = d }
            if let t = Self.timeFormatter.date(from: c.horaInicio) { horaInicio = t }
            if let t = Self.timeFormatter.date(from: c.horaFin) { horaFin = t }
        } else {
            isEditing = false
            editingId = ""
        }
    }

    var isValid: Bool {
        !titulo.trimmingCharacters(in: .whitespaces).isEmpty &&
        !costo.isEmpty &&
        (courseImage != nil || !currentImageUrl.isEmpty)
    }

    func loadLocations() { locations = SessionManager.shared.locations }

    func setCourseImage(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task { if let d = try? await item.loadTransferable(type: Data.self) { courseImage = d } }
    }
    func setInstructorImage(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task { if let d = try? await item.loadTransferable(type: Data.self) { instructorImage = d } }
    }

    func addTema() { temarios.append("") }
    func removeTema(at index: Int) { if temarios.indices.contains(index) { temarios.remove(at: index) } }

    func save() {
        guard isValid, !isSaving else { return }
        let location = locations.first { $0.name == selectedLocationName }
        let form = CoursesRepository.CourseForm(
            id: editingId,
            titulo: titulo.trimmingCharacters(in: .whitespaces),
            descripcion: descripcion,
            fecha: Self.dateFormatter.string(from: fecha),
            horaInicio: Self.timeFormatter.string(from: horaInicio),
            horaFin: Self.timeFormatter.string(from: horaFin),
            costo: costo,
            apartar: apartar,
            instructora: instructora,
            instructoraDesc: instructoraDesc,
            temarios: temarios.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty },
            ubicacionNombre: selectedLocationName.isEmpty ? nil : selectedLocationName,
            lat: location?.lat,
            lng: location?.lng,
            newCourseImage: courseImage,
            newInstructorImage: instructorImage,
            currentImageUrl: currentImageUrl,
            currentInstructorImageUrl: currentInstructorImageUrl
        )
        Task {
            isSaving = true
            let result = isEditing ? await repository.updateCourse(form)
                                   : await repository.createCourse(form)
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
