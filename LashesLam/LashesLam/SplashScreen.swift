//
//  SplashScreen.swift
//  LashesLam
//
//  Created by Alejandro Mejia v on 15/10/25.
//

import SwiftUI

struct SplashScreen: View {
    @State private var showFullName = false
        @State private var visibleText = ""
        @State private var shimmerPhase: CGFloat = 0
        @State private var offsetX: CGFloat = -200
        @State private var offsetY: CGFloat = 200
        @State private var navigateToLogin = false
        
        private let fullText = "LashesLam"
        
        var body: some View {
            ZStack {
                Color(red: 0.10, green: 0.10, blue: 0.10) // fondo oscuro (#1A1A1A)
                    .ignoresSafeArea()
                
                if !showFullName {
                    HStack(spacing: 0) {
                        Text("L")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundStyle(shimmerGradient)
                            .offset(x: offsetX)
                            .animation(.easeOut(duration: 0.8), value: offsetX)
                        
                        Text("L")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundStyle(shimmerGradient)
                            .offset(y: offsetY)
                            .animation(.easeOut(duration: 0.8), value: offsetY)
                    }
                } else {
                    Text(visibleText)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(shimmerGradient)
                        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                }
            }
            .onAppear {
                startAnimation()
            }
            .fullScreenCover(isPresented: $navigateToLogin) {
                LogIn()
            }
        }
        
        /// Gradiente animado tipo "brillo rosa"
        private var shimmerGradient: LinearGradient {
            let gradient = Gradient(colors: [
                Color(red: 1.0, green: 0.76, blue: 0.89), // rosa claro
                Color(red: 1.0, green: 0.41, blue: 0.71), // rosa intenso
                Color(red: 1.0, green: 0.76, blue: 0.89)  // vuelve al claro
            ])
            return LinearGradient(
                gradient: gradient,
                startPoint: UnitPoint(x: shimmerPhase, y: 0),
                endPoint: UnitPoint(x: shimmerPhase + 0.2, y: 1)
            )
        }
        
        /// Secuencia de animaciones
        private func startAnimation() {
            withAnimation(.easeOut(duration: 0.8)) {
                offsetX = 0
                offsetY = 0
            }
            
            // Animar shimmer de forma infinita
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                shimmerPhase = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                showFullName = true
                typeText()
            }
        }
        
        /// Simula la escritura de "LashesLam"
        private func typeText() {
            for (index, _) in fullText.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                    visibleText = String(fullText.prefix(index + 1))
                    
                    // Al terminar, espera y navega
                    if index == fullText.count - 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            navigateToLogin = true
                        }
                    }
                }
            }
        }
}

#Preview {
    SplashScreen()
}
