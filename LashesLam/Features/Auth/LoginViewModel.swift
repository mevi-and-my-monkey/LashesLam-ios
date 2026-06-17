//
//  LoginViewModel.swift
//  LashesLam
//
//  Espejo de ui/auth/LoginViewModel.kt + LoginUiState. Maneja login, registro
//  y Google Sign-In, validación, loading y errores.
//

import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoginEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var navigateToHome: Bool = false

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

    // MARK: - Helper

    private func runWithLoading(_ work: @escaping () async -> Void) {
        Task {
            isLoading = true
            await work()
            isLoading = false
        }
    }
}
