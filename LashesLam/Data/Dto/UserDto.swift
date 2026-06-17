//
//  UserDto.swift
//  LashesLam
//
//  Espejo de data/dto/UserDto.kt. Es lo que se persiste en Firestore (sin password).
//

import Foundation

struct UserDto: Codable {
    var name: String?
    var email: String?
    var uid: String?
    var phone: String?
    var address: String?
    var userPhoto: String?
    var photoUpdatedByUser: Bool = false

    /// Diccionario para escribir en Firestore con merge, omitiendo nil.
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = ["photoUpdatedByUser": photoUpdatedByUser]
        if let name = name { data["name"] = name }
        if let email = email { data["email"] = email }
        if let uid = uid { data["uid"] = uid }
        if let phone = phone { data["phone"] = phone }
        if let address = address { data["address"] = address }
        if let userPhoto = userPhoto { data["userPhoto"] = userPhoto }
        return data
    }
}
