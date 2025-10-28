//
//  LoginSheetView.swift
//  LashesLam
//
//  Created by Alejandro Mejia v on 18/10/25.
//

import SwiftUI

struct LoginSheetView: View {
    @Environment(\.dismiss) var dismiss
       var config: LashesLamConfig

       @State private var email = ""
       @State private var password = ""
       
       var body: some View {
           NavigationStack {
               VStack(spacing: 20) {
                   Text("Iniciar sesión")
                       .font(.title2)
                       .fontWeight(.bold)
                       .padding(.top, 16)
                   
                   TextField("Correo electrónico", text: $email)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .autocapitalization(.none)
                       .keyboardType(.emailAddress)
                   
                   SecureField("Contraseña", text: $password)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                   
                   PrimaryButton(
                       text: config.primaryButtonText,
                       backgroundColor: config.primaryButtonColor,
                       textColor: config.primaryTextColor
                   ){
                       config.primaryAction()
                       print("Login con: \(email) / \(password)")
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
    // Creamos un ejemplo de configuración para la vista previa
    let previewConfig = LashesLamConfig(
        logoImage: Image(systemName: "star"), // Imagen de ejemplo
        googleIcon: Image(systemName: "globe"),
        primaryAction: { print("Iniciar sesión") },
        outlinedAction: { print("Registrarse") },
        socialAction: { print("Google") }
    )
    
    LoginSheetView(config: previewConfig)
}
