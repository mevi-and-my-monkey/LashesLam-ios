//
//  LoginViewModel.swift
//  LashesLam
//
//  Espejo de ui/auth/LoginViewModel.kt + LoginUiState. Maneja login, registro
//  y Google Sign-In, validación, loading y errores.
//

import SwiftUI
import AuthenticationServices

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoginEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var navigateToHome: Bool = false

    /// Nonce en crudo para el flujo de Sign in with Apple.
    private var appleRawNonce: String?

    private let userRepository: UserRepository
    private let sessionRepository: SessionRepository

    init(userRepository: UserRepository = UserRepository(),
         sessionRepository: SessionRepository = SessionRepository()) {
        self.userRepository = userRepository
        self.sessionRepository = sessionRepository
    }

    // MARK: - Validación (igual que ValidateLoginUseCase)

    func onLoginChanged(email: String, password: String) {
        self.email = email
        self.password = password
        isLoginEnabled = validate(email: email, password: password)
    }

    private func validate(email: String, password: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$"
        let isEmailValid = email.range(of: emailRegex, options: .regularExpression) != nil
        let isPasswordValid = password.count > 6
        return isEmailValid && isPasswordValid
    }

    // MARK: - Acciones

    func login() {
        runWithLoading {
            let result = await self.userRepository.signIn(email: self.email, password: self.password)
            switch result {
            case .success:
                await self.sessionRepository.refreshSession()
                self.navigateToHome = true
            case .failure(let error):
                self.errorMessage = error.userMessage
            }
        }
    }

    func register(name: String, email: String, password: String, phone: String?, address: String?) {
        let user = UserModel(
            name: name,
            email: email,
            phone: phone,
            address: address,
            password: password
        )
        runWithLoading {
            let result = await self.userRepository.register(user)
            switch result {
            case .success:
                await self.sessionRepository.refreshSession()
                self.navigateToHome = true
            case .failure(let error):
                self.errorMessage = error.userMessage
            }
        }
    }

    func signInWithGoogle(presenting viewController: UIViewController) {
        runWithLoading {
            let result = await self.userRepository.signInWithGoogle(presenting: viewController)
            switch result {
            case .success:
                await self.sessionRepository.refreshSession()
                self.navigateToHome = true
            case .failure(let error):
                self.errorMessage = error.userMessage
            }
        }
    }

    // MARK: - Sign in with Apple

    /// Configura la solicitud de Apple: genera el nonce y pide nombre/email.
    func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = AppleSignInHelper.randomNonce()
        appleRawNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = AppleSignInHelper.sha256(nonce)
    }

    /// Procesa el resultado del botón de Apple.
    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure:
            // El usuario canceló o hubo error de la hoja de Apple; no mostramos error intrusivo.
            return
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8),
                  let rawNonce = appleRawNonce else {
                errorMessage = "No se pudo completar el inicio con Apple"
                return
            }
            let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }.joined(separator: " ")

            runWithLoading {
                let result = await self.userRepository.signInWithApple(
                    idToken: idToken,
                    rawNonce: rawNonce,
                    fullName: fullName.isEmpty ? nil : fullName
                )
                switch result {
                case .success:
                    await self.sessionRepository.refreshSession()
                    self.navigateToHome = true
                case .failure(let error):
                    self.errorMessage = error.userMessage
                }
            }
        }
    }

    // MARK: - Helper

    private func runWithLoading(_ work: @escaping () async -> Void) {
        Task {
            isLoading = true
            await work()
            isLoading = false
        }
    }
}
