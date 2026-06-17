//
//  SessionManager.swift
//  LashesLam
//
//  Espejo de session/SessionManager.kt. Estado global de la sesión observable por la UI.
//

import Foundation
import Combine

final class SessionManager: ObservableObject {
    static let shared = SessionManager()
    private init() {}

    @Published var isUserAdmin: Bool = false
    @Published var isUserInvited: Bool = false

    @Published var currentUserId: String?
    @Published var nameUser: String?
    @Published var emailUser: String?
    @Published var photoUrl: String?

    @Published var whatsApp: String?
    @Published var instagram: String?
    @Published var facebook: String?

    @Published var locations: [LocationItem] = []
    @Published var shippingCost: Double = 0.0

    /// Lista de emails admin obtenida de Remote Config (clave list_admin).
    private var adminEmailsCache: [String] = []

    func setAdminEmails(_ emails: [String]) {
        adminEmailsCache = emails
    }

    /// Verifica si un email es admin (igual que SessionManager.isAdmin de Android).
    func isAdmin(_ email: String) -> Bool {
        adminEmailsCache.contains(email)
    }

    /// Limpia los datos del usuario al cerrar sesión.
    func clearUserSession() {
        currentUserId = nil
        nameUser = nil
        emailUser = nil
        photoUrl = nil
        isUserAdmin = false
        isUserInvited = false
    }
}
