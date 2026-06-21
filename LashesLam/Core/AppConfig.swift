//
//  AppConfig.swift
//  LashesLam
//
//  Interruptores de configuración de la app.
//

enum AppConfig {
    /// Sign in with Apple requiere el Apple Developer Program de pago.
    /// Cuando tengas la cuenta de pago: pon esto en `true` y vuelve a agregar
    /// `CODE_SIGN_ENTITLEMENTS: LashesLam/LashesLam.entitlements` en project.yml,
    /// luego `xcodegen generate`. (Es obligatorio antes de enviar a la App Store.)
    static let signInWithAppleEnabled = false
}
