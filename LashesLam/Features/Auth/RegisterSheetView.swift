//
//  RegisterSheetView.swift
//  LashesLam
//
//  Hoja de registro de nueva cuenta.
//

import SwiftUI

struct RegisterSheetView: View {
    @Environment(\.dismiss) var dismiss
    var config: LashesLamConfig
    @ObservedObject var viewModel: LoginViewModel

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var address = ""

    private var isEnabled: Bool {
        let emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$"
        let validEmail = email.range(of: emailRegex, options: .regularExpression) != nil
        return !name.isEmpty && validEmail && password.count > 6
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Registrarse")
                        .font(.title2).fontWeight(.bold)
                        .padding(.top, 16)

                    TextField("Nombre completo", text: $name)
                        .textFieldStyle(.roundedBorder)

                    TextField("Correo electrónico", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()

                    SecureField("Contraseña", text: $password)
                        .textFieldStyle(.roundedBorder)

                    TextField("Teléfono (opcional)", text: $phone)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)

                    TextField("Dirección (opcional)", text: $address)
                        .textFieldStyle(.roundedBorder)

                    PrimaryButton(
                        text: config.outlinedButtonText,
                        backgroundColor: config.primaryButtonColor,
                        textColor: config.primaryTextColor
                    ) {
                        viewModel.register(
                            name: name,
                            email: email,
                            password: password,
                            phone: phone.isEmpty ? nil : phone,
                            address: address.isEmpty ? nil : address
                        )
                        dismiss()
                    }
                    .disabled(!isEnabled)
                    .opacity(isEnabled ? 1 : 0.5)

                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
