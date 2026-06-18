//
//  ProfileViewModel.swift
//  LashesLam
//
//  Espejo de ui/profile/ProfileViewModel.kt. Carga datos del usuario, actualiza
//  foto/dirección/teléfono y cierra sesión.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var user = UserModel()
    @Published var photoUser: String = ""
    @Published var isLoading = false

    // Mensajes para diálogos (success / error).
    @Published var successMessage: String?
    @Published var errorMessage: String?

    private let userRepository: UserRepository
    private let session = SessionManager.shared

    init(userRepository: UserRepository = UserRepository()) {
        self.userRepository = userRepository
    }

    func loadUserData() {
        let currentPhoto = Auth.auth().currentUser?.photoURL?.absoluteString ?? ""
        photoUser = currentPhoto
        Task {
            guard let fetched = await userRepository.fetchUser() else { return }
            user = fetched
            let storedPhoto = fetched.userPhoto ?? ""
            // Respeta la foto personalizada por el usuario; si no, usa la de Google/almacenada.
            if fetched.photoUpdatedByUser && !storedPhoto.isEmpty {
                photoUser = storedPhoto
            } else if photoUser.isEmpty {
                photoUser = storedPhoto
            }
        }
    }

    func updateProfilePhoto(data: Data) {
        Task {
            isLoading = true
            let result = await userRepository.updateProfilePhoto(data: data)
            isLoading = false
            switch result {
            case .success(let url):
                photoUser = url
                user.userPhoto = url
                user.photoUpdatedByUser = true
                session.photoUrl = url
                successMessage = "Foto de perfil actualizada exitosamente"
            case .failure:
                errorMessage = "Error al actualizar la foto de perfil"
            }
        }
    }

    func updateAddress(_ address: String) {
        Task {
            isLoading = true
            let result = await userRepository.updateAddress(address)
            isLoading = false
            switch result {
            case .success:
                user.address = address
                successMessage = "Dirección actualizada exitosamente"
            case .failure(let error):
                errorMessage = error.userMessage
            }
        }
    }

    func updatePhone(_ phone: String) {
        Task {
            isLoading = true
            let result = await userRepository.updatePhone(phone)
            isLoading = false
            switch result {
            case .success:
                user.phone = phone
                successMessage = "Teléfono actualizado exitosamente"
            case .failure(let error):
                errorMessage = error.userMessage
            }
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        session.clearUserSession()
    }
}
