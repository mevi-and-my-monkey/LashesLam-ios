//
//  ErrorMapper.swift
//  LashesLam
//
//  Espejo de data/error/FirebaseErrorMapper.kt: traduce NSError de Firebase a AppError.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum ErrorMapper {
    static func map(_ error: Error) -> AppError {
        let nsError = error as NSError

        // Errores de Firestore (dominio FIRFirestoreErrorDomain).
        if nsError.domain == FirestoreErrorDomain {
            if nsError.code == FirestoreErrorCode.unavailable.rawValue {
                return .network
            }
            return .unknown(nsError.localizedDescription)
        }

        // Errores de FirebaseAuth.
        if nsError.domain == AuthErrorDomain {
            switch AuthErrorCode(rawValue: nsError.code) {
            case .userNotFound:
                return .userNotFound
            case .wrongPassword, .invalidCredential, .invalidEmail:
                return .invalidCredentials
            case .networkError:
                return .network
            default:
                return .unknown(nsError.localizedDescription)
            }
        }

        // Sin conexión genérica.
        if nsError.domain == NSURLErrorDomain {
            return .network
        }

        return .unknown(nsError.localizedDescription)
    }
}
