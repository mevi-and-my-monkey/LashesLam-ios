//
//  AppDialog.swift
//  LashesLam
//
//  Diálogo custom estilo Android (CustomDialog.kt / ErrorDialog / SuccessDialog):
//  tarjeta centrada con icono, título, mensaje y botón(es). Reemplaza los alerts
//  nativos para homologar el look con Android.
//

import SwiftUI

enum AppDialogKind {
    case error, success, warning

    var icon: String {
        switch self {
        case .error: return "xmark.octagon.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }

    var background: Color {
        switch self {
        case .error: return Color(red: 1.0, green: 0.79, blue: 0.79)     // #FFC9C9
        case .success: return Color(red: 0.73, green: 0.98, blue: 0.75)  // #B9FBC0
        case .warning: return Color(red: 1.0, green: 0.91, blue: 0.70)   // #FFE9B3
        }
    }

    var accent: Color {
        switch self {
        case .error: return Color(red: 0.96, green: 0.26, blue: 0.21)    // #F44336
        case .success: return Color(red: 0.30, green: 0.69, blue: 0.31)  // #4CAF50
        case .warning: return Color(red: 0.90, green: 0.60, blue: 0.0)
        }
    }
}

struct AppDialog: View {
    let kind: AppDialogKind
    let title: String
    let message: String
    var primaryText: String = "Aceptar"
    var onPrimary: () -> Void = {}
    var secondaryText: String? = nil
    var onSecondary: () -> Void = {}

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: kind.icon)
                    .font(.system(size: 56))
                    .foregroundColor(kind.accent)

                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)

                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                HStack(spacing: 8) {
                    Button(action: onPrimary) {
                        Text(primaryText)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(kind.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if let secondaryText {
                        Button(action: onSecondary) {
                            Text(secondaryText)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 1))
                        }
                    }
                }
            }
            .padding(24)
            .background(kind.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 32)
        }
    }
}

extension View {
    /// Muestra un diálogo de error custom cuando `message` no es nil.
    func errorDialog(_ message: Binding<String?>, title: String = "Error") -> some View {
        overlay {
            if let msg = message.wrappedValue {
                AppDialog(kind: .error, title: title, message: msg) {
                    message.wrappedValue = nil
                }
            }
        }
    }

    /// Muestra un diálogo de éxito custom cuando `message` no es nil.
    func successDialog(_ message: Binding<String?>, title: String = "¡Listo!") -> some View {
        overlay {
            if let msg = message.wrappedValue {
                AppDialog(kind: .success, title: title, message: msg) {
                    message.wrappedValue = nil
                }
            }
        }
    }
}
