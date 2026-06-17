//
//  UserModel.swift
//  LashesLam
//
//  Espejo de network/UserModel.kt. Modelo de dominio usado en el registro.
//  password/confirmPassword existen solo en memoria; no se persisten.
//

import Foundation

struct UserModel {
    var name: String?
    var email: String?
    var uid: String?
    var phone: String?
    var address: String?
    var userPhoto: String?
    var photoUpdatedByUser: Bool = false
    var password: String?
    var confirmPassword: String?

    /// Convierte a UserDto (descarta password/confirmPassword), igual que toDto() en Android.
    func toDto() -> UserDto {
        UserDto(
            name: name,
            email: email,
            uid: uid,
            phone: phone,
            address: address,
            userPhoto: userPhoto,
            photoUpdatedByUser: photoUpdatedByUser
        )
    }
}
