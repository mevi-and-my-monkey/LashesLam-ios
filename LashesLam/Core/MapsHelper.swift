//
//  MapsHelper.swift
//  LashesLam
//
//  Abre una ubicación en Google Maps (si está instalado) o en Apple Maps.
//  Equivalente a Utilities.openGoogleMaps de Android.
//

import UIKit

enum MapsHelper {
    static func openLocation(lat: Double, lng: Double, name: String? = nil) {
        // Intenta Google Maps; si no está, cae a Apple Maps.
        if let google = URL(string: "comgooglemaps://?q=\(lat),\(lng)"),
           UIApplication.shared.canOpenURL(google) {
            UIApplication.shared.open(google)
            return
        }
        let query = name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let apple = query.map { "http://maps.apple.com/?ll=\(lat),\(lng)&q=\($0)" }
            ?? "http://maps.apple.com/?ll=\(lat),\(lng)"
        if let url = URL(string: apple) { UIApplication.shared.open(url) }
    }

    static func hasLocation(lat: Double?, lng: Double?) -> Bool {
        guard let lat, let lng else { return false }
        return !(lat == 0 && lng == 0)
    }
}
