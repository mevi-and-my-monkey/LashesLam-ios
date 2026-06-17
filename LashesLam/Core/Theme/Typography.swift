//
//  Typography.swift
//  LashesLam
//
//  Tipografía de la app. Los títulos usan Cormorant Garamond en cursiva,
//  igual que el tema de Android (ui/theme/Type.kt).
//

import SwiftUI

extension Font {
    /// Título grande estilizado (equivalente a titleLarge de Material).
    static func appTitle(_ size: CGFloat = 24) -> Font {
        // Si la fuente Cormorant Garamond está embebida se usa; si no, cae al sistema.
        if UIFont(name: "CormorantGaramond-Bold", size: size) != nil {
            return .custom("CormorantGaramond-Bold", size: size)
        }
        return .system(size: size, weight: .bold)
    }

    /// Subtítulo / título medio.
    static func appTitleMedium(_ size: CGFloat = 22) -> Font {
        if UIFont(name: "CormorantGaramond-Regular", size: size) != nil {
            return .custom("CormorantGaramond-Regular", size: size)
        }
        return .system(size: size, weight: .regular)
    }
}
