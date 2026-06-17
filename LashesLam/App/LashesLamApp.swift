//
//  LashesLamApp.swift
//  LashesLam
//
//  Punto de entrada. Configura Firebase y muestra el AppRootView.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct LashesLamApp: App {

    init() {
        // Configura Firebase solo si existe el GoogleService-Info.plist.
        if FirebaseApp.app() == nil, Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .onOpenURL { url in
                    // Necesario para completar el flujo de Google Sign-In.
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
