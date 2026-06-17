//
//  LoginSheetView.swift
//  LashesLam
//
//  Hoja de inicio de sesión con email y contraseña.
//

import SwiftUI

struct LoginSheetView: View {
    @Environment(\.dismiss) var dismiss
    var config: LashesLamConfig
    @ObservedObject var viewModel: LoginViewModel

    @State private var email = ""
    @State private var password = ""

    private var isEnabled: Bool {
        let emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$"
        let validEmail = email.range(of: emailRegex, options: .regularExpression) != nil
        return validEmail && password.count > 6
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Iniciar sesión")
                    .font(.title2).fontWeight(.bold)
                    .padding(.top, 16)

                TextField("Correo electrónico", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()

                SecureField("Contraseña", text: $password)
                    .textFieldStyle(.roundedBorder)

                PrimaryButton(
                    text: config.primaryButtonText,
                    backgroundColor: config.primaryButtonColor,
                    textColor: config.primaryTextColor
                ) {
                    viewModel.onLoginChanged(email: email, password: password)
                    viewModel.login()
                    dismiss()
                }
                .disabled(!isEnabled)
                .opacity(isEnabled ? 1 : 0.5)

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
