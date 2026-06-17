//
//  HomeView.swift
//  LashesLam
//
//  Stub de la pantalla principal para esta etapa. Las features reales (tienda,
//  cursos, servicios, citas, favoritos, perfil) se construyen en etapas posteriores.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct HomeView: View {
    @EnvironmentObject var session: SessionManager
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 16) {
                Image("logo_app")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())

                Text("¡Hola, \(session.nameUser ?? "bienvenida")!")
                    .font(.appTitle(26))
                    .italic()
                    .foregroundColor(AppColors.onBackground)

                if let email = session.emailUser {
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(AppColors.onSurfaceVariant)
                }

                if session.isUserAdmin {
                    Label("Modo administrador", systemImage: "crown.fill")
                        .font(.footnote.bold())
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(AppColors.purpleSecondary.opacity(0.15))
                        .foregroundColor(AppColors.purpleSecondary)
                        .clipShape(Capsule())
                }

                Text("Próximamente: tienda, cursos, servicios y citas.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 4)

                Button(role: .destructive) {
                    logout()
                } label: {
                    Text("Cerrar sesión")
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.pinkPrimary)
                        .foregroundColor(AppColors.onPrimary)
                        .cornerRadius(12)
                }
                .padding(.top, 24)
                .padding(.horizontal, 32)
            }
            .padding()
        }
    }

    private func logout() {
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        session.clearUserSession()
        // Reinicia el flujo volviendo a la raíz.
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first(where: { $0.isKeyWindow }) {
            window.rootViewController = UIHostingController(rootView: AppRootView())
            window.makeKeyAndVisible()
        }
    }
}
