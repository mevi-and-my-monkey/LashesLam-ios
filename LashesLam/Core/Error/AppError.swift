//
//  AppError.swift
//  LashesLam
//
//  Espejo de core/error/AppError.kt + ui/common/extensions.kt (toUserMessage()).
//

import Foundation

enum AppError: Error {
    case network
    case invalidCredentials
    case userNotFound
    case unknown(String?)

    /// Mensaje en español para mostrar al usuario (igual que Android).
    var userMessage: String {
        switch self {
        case .network:
            return "Sin conexión a internet"
        case .invalidCredentials:
            return "Correo o contraseña incorrectos"
        case .userNotFound:
            return "Usuario no encontrado"
        case .unknown(let message):
            return message?.isEmpty == false ? message! : "Ocurrió un error, intenta nuevamente"
        }
    }
}
