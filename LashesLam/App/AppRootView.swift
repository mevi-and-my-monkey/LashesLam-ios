//
//  AppRootView.swift
//  LashesLam
//
//  Decide la pantalla raíz: Splash → (Login | Home) según la sesión de Firebase.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

struct AppRootView: View {

    private enum Route {
        case splash, login, home
    }

    @State private var route: Route = .splash
    @StateObject private var loginViewModel = LoginViewModel()
    @StateObject private var session = SessionManager.shared

    private let sessionRepository = SessionRepository()

    var body: some View {
        Group {
            switch route {
            case .splash:
                SplashScreen(onFinished: handleSplashFinished)
            case .login:
                LogInView(viewModel: loginViewModel)
            case .home:
                HomeView()
            }
        }
        .environmentObject(session)
        .onChange(of: loginViewModel.navigateToHome) { goHome in
            if goHome { withAnimation { route = .home } }
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
                await MainActor.run { withAnimation { route = .home } }
            }
        } else {
            withAnimation { route = .login }
        }
    }
}
