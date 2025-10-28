//
//  RegisterSheetView.swift
//  LashesLam
//
//  Created by Alejandro Mejia v on 18/10/25.
//

import SwiftUI

struct RegisterSheetView: View {
    @Environment(\.dismiss) var dismiss
    var config: LashesLamConfig
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Registrarse")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 16)
                
                TextField("Nombre completo", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Correo electrónico", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Contraseña", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                PrimaryButton(
                    text: config.outlinedButtonText,
                    backgroundColor: config.primaryButtonColor,
                    textColor: config.primaryTextColor
                ){
                    config.outlinedAction()
                    print("Registro con: \(name) / \(email) / \(password)")
                    dismiss()
                }
                
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

#Preview {
    let previewConfig = LashesLamConfig(
        logoImage: Image(systemName: "star"),
        googleIcon: Image(systemName: "globe"),
        primaryAction: { print("Iniciar sesión") },
        outlinedAction: { print("Registrarse") },
        socialAction: { print("Google") }
    )
    
    VStack(spacing: 40) {
        LoginSheetView(config: previewConfig)
        RegisterSheetView(config: previewConfig)
    }
}
