//
//  LogIn.swift
//  LashesLam
//
//  Created by Alejandro Mejia v on 15/10/25.
//

import SwiftUI

struct LogInView: View {
    var config: LashesLamConfig
    @State private var showLogo = false
    @State private var showingSheet: SheetType? = nil
    
    enum SheetType: Identifiable {
        case login, register
        
        var id: Int { hashValue }
    }
    
    var body: some View {
        WavyBackground(
            backgroundColor: config.backgroundColor,
            bigWaveColor: config.bigWaveColor,
            smallWaveColor: config.smallWaveColor
        ) {
            VStack(spacing: 34) {
                
                // --- Logo animado ---
                config.logoImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .scaleEffect(showLogo ? 1 : 0.6)
                    .opacity(showLogo ? 1 : 0)
                    .animation(.easeOut(duration: 0.8), value: showLogo)
                    .padding(.top, 100)
                    .onAppear {
                        showLogo = true
                    }
                
                Spacer()
                
                // --- Texto y botones ---
                VStack(spacing: 12) {
                    Spacer()
                    Text(config.welcomeText)
                        .font(.system(size: 24, weight: .medium))
                        .italic()
                        .foregroundColor(.black)
                    Spacer()
                    
                    PrimaryButton(
                        text: config.primaryButtonText,
                        backgroundColor: config.primaryButtonColor,
                        textColor: config.primaryTextColor,
                    ){
                        config.primaryAction()
                        showingSheet = .login
                    }
                    
                    OutlinedButton(
                        text: config.outlinedButtonText,
                        textColor: config.outlinedTextColor,
                        borderColor: config.outlinedBorderColor,
                    ){
                        config.outlinedAction()
                        showingSheet = .register
                    }
                }
                
                Spacer()
                Spacer()
                
                // --- Continuar con ---
                VStack(spacing: 24) {
                    HStack(alignment: .center) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        Text(config.continueWithText)
                            .font(.system(size: 14))
                            .foregroundColor(Color.gray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .minimumScaleFactor(0.8)
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    OutlinedButton(
                        text: config.socialButtonText,
                        icon: config.googleIcon,
                        textColor: config.outlinedTextColor,
                        borderColor: config.outlinedBorderColor,
                        action: config.socialAction
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(item: $showingSheet) { item in
                switch item {
                case .login:
                    LoginSheetView(config: config)
                case .register:
                    RegisterSheetView(config: config)
                }
            }
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView(config: LashesLamConfig(
            logoImage: Image("logo_app"),
            googleIcon: Image("ic_google_one"),
            primaryAction: { print("Iniciar sesión") },
            outlinedAction: { print("Registrarse") },
            socialAction: { print("Google") }
        ))
    }
}
