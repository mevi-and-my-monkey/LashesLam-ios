//
//  HomeView.swift
//  LashesLam
//
//  Pestaña de Inicio. Stub por ahora; las features reales (tienda, cursos,
//  servicios, citas) se construyen en etapas posteriores.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: SessionManager

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
            }
            .padding()
        }
    }
}
