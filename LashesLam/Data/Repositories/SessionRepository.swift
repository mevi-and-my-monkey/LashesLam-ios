//
//  SessionRepository.swift
//  LashesLam
//
//  Espejo de data/SessionRepositoryImpl.kt + parte de SessionManager.kt (Android).
//  Lee Remote Config (admins, redes, sucursales, envío) y sincroniza nombre/foto.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseRemoteConfig

final class SessionRepository {

    // Claves de Remote Config (mismas que core/Strings.kt en Android).
    private enum RemoteKeys {
        static let listAdmin = "list_admin"
        static let whatsapp = "whatsapp_administrador"
        static let instagram = "instagram"
        static let facebook = "facebook"
        static let locations = "sucursales"
        static let shippingCost = "costo_envio"
    }

    // Defaults (mismos que core/Strings.kt).
    private enum Defaults {
        static let whatsapp = "5514023853"
        static let instagram = "https://instagram.com/"
        static let facebook = "https://facebook.com/"
    }

    private let session = SessionManager.shared
    private var auth: Auth { Auth.auth() }
    private var firestore: Firestore { Firestore.firestore() }

    var isLoggedIn: Bool { auth.currentUser != nil }
    var email: String? { auth.currentUser?.email }
    var uid: String? { auth.currentUser?.uid }

    // MARK: - Remote Config

    @MainActor
    func refreshAdmins() async {
        let remoteConfig = RemoteConfig.remoteConfig()
        // Sin caché: siempre trae el valor más reciente, igual que Android
        // (minimumFetchIntervalInSeconds = 0). Si no, iOS sirve valores viejos ~12h
        // (por eso el envío mostraba 60 en vez del 0 configurado en Remote Config).
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        do {
            _ = try await remoteConfig.fetchAndActivate()
        } catch {
            session.setAdminEmails([])
            return
        }

        let adminsJson = remoteConfig[RemoteKeys.listAdmin].stringValue
        session.setAdminEmails(parseAdminList(adminsJson))

        let locationsJson = remoteConfig[RemoteKeys.locations].stringValue
        session.locations = parseLocations(locationsJson)

        let whatsApp = remoteConfig[RemoteKeys.whatsapp].stringValue
        session.whatsApp = whatsApp.isEmpty ? Defaults.whatsapp : whatsApp

        let instagram = remoteConfig[RemoteKeys.instagram].stringValue
        session.instagram = instagram.isEmpty ? Defaults.instagram : instagram

        let facebook = remoteConfig[RemoteKeys.facebook].stringValue
        session.facebook = facebook.isEmpty ? Defaults.facebook : facebook

        session.shippingCost = remoteConfig[RemoteKeys.shippingCost].numberValue.doubleValue
    }

    func isAdmin(_ email: String) -> Bool { session.isAdmin(email) }

    @MainActor
    func setAdmin(_ value: Bool) {
        session.isUserAdmin = value
        session.isUserInvited = false
    }

    @MainActor
    func setSessionManager() {
        session.currentUserId = uid
        session.emailUser = email
    }

    // MARK: - Nombre y foto (lee Firestore, respeta foto personalizada)

    @MainActor
    func setName() async {
        guard let user = auth.currentUser else { return }
        var name = user.displayName
        if let snapshot = try? await firestore.document(FirestorePaths.Users.document(user.uid)).getDocument(),
           let firestoreName = snapshot.get(FirestorePaths.Users.userName) as? String,
           !firestoreName.isEmpty {
            name = firestoreName
        }
        if let firstName = name?.split(separator: " ").first.map(String.init), !firstName.isEmpty {
            session.nameUser = firstName
        }
    }

    @MainActor
    func setPhoto() async {
        guard let user = auth.currentUser else { return }
        let googlePhoto = user.photoURL?.absoluteString
        let userDoc = firestore.document(FirestorePaths.Users.document(user.uid))

        guard let snapshot = try? await userDoc.getDocument() else {
            if let googlePhoto, !googlePhoto.isEmpty { session.photoUrl = googlePhoto }
            return
        }

        let storedPhoto = snapshot.get(FirestorePaths.Users.userPhoto) as? String
        let photoUpdatedByUser = (snapshot.get(FirestorePaths.Users.photoUpdatedByUser) as? Bool) ?? false

        // El usuario personalizó su foto: se respeta y no se sincroniza con Google.
        if photoUpdatedByUser {
            if let storedPhoto, !storedPhoto.isEmpty { session.photoUrl = storedPhoto }
            return
        }

        if let googlePhoto, !googlePhoto.isEmpty {
            if googlePhoto != storedPhoto {
                try? await userDoc.setData([FirestorePaths.Users.userPhoto: googlePhoto], merge: true)
            }
            session.photoUrl = googlePhoto
            return
        }

        if let storedPhoto, !storedPhoto.isEmpty { session.photoUrl = storedPhoto }
    }

    // MARK: - Refresco completo de sesión (espejo de RefreshSessionUseCase)

    @MainActor
    func refreshSession() async {
        await refreshAdmins()
        await setName()
        await setPhoto()
        if let email {
            setAdmin(isAdmin(email))
            setSessionManager()
        }
    }

    // MARK: - Parsers

    private func parseAdminList(_ json: String) -> [String] {
        guard let data = json.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [String] else {
            return []
        }
        return array
    }

    private func parseLocations(_ json: String) -> [LocationItem] {
        guard let data = json.data(using: .utf8),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let array = root["locations"] as? [[String: Any]] else {
            return []
        }
        return array.compactMap { obj in
            guard let name = obj["name"] as? String,
                  let lat = (obj["lat"] as? NSNumber)?.doubleValue,
                  let lng = (obj["lng"] as? NSNumber)?.doubleValue else { return nil }
            return LocationItem(name: name, lat: lat, lng: lng)
        }
    }
}
