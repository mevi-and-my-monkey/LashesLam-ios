//
//  LogIn.swift
//  LashesLam
//
//  Created by Alejandro Mejia v on 15/10/25.
//

import SwiftUI

struct LogIn: View {
    var body: some View {
        ZStack(alignment: .top) {
            // Fondo con olas
            WavyBackground()

            VStack(spacing: 16) {
                Spacer().frame(height: 100)

                // Logo circular
                Image("logo_app")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())

                Spacer().frame(height: 130)

                // Texto de bienvenida
                Text("¡Bienvenida!")
                    .font(.system(size: 24, weight: .medium, design: .default))
                    .italic()
                    .foregroundColor(.black)
                    .padding(.bottom, 16)

                Spacer().frame(height: 40)

                // Botón de inicio de sesión
                Button(action: {
                    // Acción Iniciar Sesión
                }) {
                    Text("Iniciar sesión")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 48)

                // Botón de registro
                Button(action: {
                    // Acción Registrarse
                }) {
                    Text("Registrarse")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 48)

                Spacer().frame(height: 60)

                // División con "Continuar con"
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    Text("Continuar con")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.horizontal, 32)

                Spacer().frame(height: 5)

                // Botón Google
                Button(action: {
                    // Acción iniciar con Google
                }) {
                    HStack {
                        Image("ic_google_one")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 20, height: 20)
                        Text("Google")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 64)

                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

struct WavyBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Fondo rosa
                Color(red: 1.0, green: 0.93, blue: 0.93)
                    .ignoresSafeArea()

                // Olas dibujadas con Path
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height

                    // Ola grande
                    path.move(to: CGPoint(x: 0, y: height * 0.28))
                    path.addQuadCurve(
                        to: CGPoint(x: width, y: height * 0.28),
                        control: CGPoint(x: width / 2, y: height * 0.43)
                    )
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.closeSubpath()
                }
                .fill(Color(red: 1.0, green: 0.96, blue: 0.96))

                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height

                    // Ola pequeña (frontal)
                    path.move(to: CGPoint(x: 0, y: height * 0.3))
                    path.addQuadCurve(
                        to: CGPoint(x: width, y: height * 0.3),
                        control: CGPoint(x: width / 2, y: height * 0.45)
                    )
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.closeSubpath()
                }
                .fill(Color.white)
            }
        }
    }
}

#Preview {
    LogIn()
}
