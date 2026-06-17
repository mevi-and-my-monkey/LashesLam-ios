//
//  LocationItem.swift
//  LashesLam
//
//  Espejo de network/LocationItem.kt (sucursales desde Remote Config).
//

import Foundation

struct LocationItem: Identifiable {
    var id: String { name }
    let name: String
    let lat: Double
    let lng: Double
}
