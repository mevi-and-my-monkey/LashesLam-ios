//
//  LogInView.swift
//  LashesLam
//
//  Pantalla principal de autenticación con fondo ondulado, logo animado y
//  botones de iniciar sesión / registrarse / Google. Cableada al LoginViewModel.
//

import SwiftUI
import AuthenticationServices

struct LogInView: View {
    var config: LashesLamConfig = LashesLamConfig()
    @ObservedObject var viewModel: LoginViewModel

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

                config.logoImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .scaleEffect(showLogo ? 1 : 0.6)
                    .opacity(showLogo ? 1 : 0)
                    .animation(.easeOut(duration: 0.8), value: showLogo)
                    .padding(.top, 100)
                    .onAppear { showLogo = true }

                Spacer()

                VStack(spacing: 12) {
                    Spacer()
                    Text(config.welcomeText)
                        .font(.appTitle(24))
                        .italic()
                        .foregroundColor(AppColors.onBackground)
                    Spacer()

                    PrimaryButton(
                        text: config.primaryButtonText,
                        backgroundColor: config.primaryButtonColor,
                        textColor: config.primaryTextColor
                    ) {
                        showingSheet = .login
                    }

                    OutlinedButton(
                        text: config.outlinedButtonText,
                        textColor: config.outlinedTextColor,
                        borderColor: config.outlinedBorderColor
                    ) {
                        showingSheet = .register
                    }
                }

                Spacer()
                Spacer()

                VStack(spacing: 24) {
                    HStack(alignment: .center) {
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                        Text(config.continueWithText)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                    }
                    OutlinedButton(
                        text: config.socialButtonText,
                        icon: config.googleIcon,
                        textColor: config.outlinedTextColor,
                        borderColor: config.outlinedBorderColor
                    ) {
                        if let vc = UIApplication.shared.topViewController {
                            viewModel.signInWithGoogle(presenting: vc)
                        }
                    }

                    // Requiere Apple Developer Program de pago (ver AppConfig).
                    if AppConfig.signInWithAppleEnabled {
                        SignInWithAppleButton(.signIn) { request in
                            viewModel.configureAppleRequest(request)
                        } onCompletion: { result in
                            viewModel.handleAppleCompletion(result)
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(item: $showingSheet) { item in
                switch item {
                case .login:
                    LoginSheetView(config: config, viewModel: viewModel)
                case .register:
                    RegisterSheetView(config: config, viewModel: viewModel)
                }
            }
            .overlay { GenericLoading(isLoading: viewModel.isLoading) }
            .errorDialog($viewModel.errorMessage)
        }
    }
}
