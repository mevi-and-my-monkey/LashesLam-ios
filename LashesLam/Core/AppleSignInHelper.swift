//
//  AppleSignInHelper.swift
//  LashesLam
//
//  Utilidades para "Iniciar sesión con Apple" + Firebase: genera un nonce
//  aleatorio y su hash SHA256 (Firebase exige el nonce para validar el token).
//

import Foundation
import CryptoKit

enum AppleSignInHelper {
    /// Genera un nonce aleatorio seguro.
    static func randomNonce(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var random: UInt8 = 0
            _ = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if random < charset.count {
                result.append(charset[Int(random)])
                remaining -= 1
            }
        }
        return result
    }

    /// SHA256 del nonce (lo que se envía en la solicitud a Apple).
    static func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}
