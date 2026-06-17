//
//  StoragePaths.swift
//  LashesLam
//
//  Réplica de data/constants/StoragePaths.kt.
//

import Foundation

enum StoragePaths {
    enum Users {
        private static let root = "users"
        private static let profileImage = "profile.jpg"
        static func profilePhoto(_ userId: String) -> String { "\(root)/\(userId)/\(profileImage)" }
    }
}
