//
//  LashesLamConfig.swift
//  LashesLam
//
//  Configuración visual de la pantalla de login (colores, imágenes y textos).
//

import SwiftUI

struct LashesLamConfig {
    // Colores
    var backgroundColor: Color = AppColors.background
    var bigWaveColor: Color = AppColors.surfaceVariant
    var smallWaveColor: Color = AppColors.surface
    var primaryButtonColor: Color = AppColors.pinkPrimary
    var primaryTextColor: Color = AppColors.onPrimary
    var outlinedTextColor: Color = AppColors.onSecondary
    var outlinedBorderColor: Color = AppColors.outline

    // Imágenes
    var logoImage: Image = Image("logo_lashes")
    var googleIcon: Image? = Image("ic_google_one")

    // Textos
    var welcomeText: String = "¡Bienvenida!"
    var primaryButtonText: String = "Iniciar sesión"
    var outlinedButtonText: String = "Registrarse"
    var continueWithText: String = "Continuar con"
    var socialButtonText: String = "Google"
}
