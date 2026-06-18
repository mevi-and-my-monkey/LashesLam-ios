//
//  AppRootView.swift
//  LashesLam
//
//  Decide la pantalla raíz: Splash → (Login | Main) según la sesión de Firebase.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

struct AppRootView: View {

    private enum Route {
        case splash, login, main
    }

    @State private var route: Route = .splash
    @StateObject private var loginViewModel = LoginViewModel()
    @StateObject private var session = SessionManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false

    private let sessionRepository = SessionRepository()

    var body: some View {
        Group {
            switch route {
            case .splash:
                SplashScreen(onFinished: handleSplashFinished)
            case .login:
                LogInView(viewModel: loginViewModel)
            case .main:
                MainTabView(onLogout: handleLogout)
            }
        }
        .environmentObject(session)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onChange(of: loginViewModel.navigateToHome) { goHome in
            if goHome {
                FavoritesManager.shared.load()
                withAnimation { route = .main }
            }
        }
    }

    private func handleSplashFinished() {
        guard FirebaseApp.app() != nil else {
            // Sin GoogleService-Info.plist: se muestra el login (sin auth real).
            route = .login
            return
        }
        if Auth.auth().currentUser != nil {
            Task {
                await sessionRepository.refreshSession()
                await MainActor.run {
                    FavoritesManager.shared.load()
                    withAnimation { route = .main }
                }
            }
        } else {
            withAnimation { route = .login }
        }
    }

    private func handleLogout() {
        FavoritesManager.shared.clear()
        loginViewModel.navigateToHome = false
        withAnimation { route = .login }
    }
}
