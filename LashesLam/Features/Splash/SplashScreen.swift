//
//  SplashScreen.swift
//  LashesLam
//
//  Splash animado (efecto shimmer + escritura del nombre). Al terminar invoca
//  onFinished; la navegación la decide AppRootView.
//

import SwiftUI

struct SplashScreen: View {
    var onFinished: () -> Void = {}

    @State private var showFullName = false
    @State private var visibleText = ""
    @State private var shimmerPhase: CGFloat = 0
    @State private var offsetX: CGFloat = -200
    @State private var offsetY: CGFloat = 200

    private let fullText = "LashesLam"

    var body: some View {
        ZStack {
            Color(red: 0.10, green: 0.10, blue: 0.10)
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

            // Versión en la parte inferior (igual que Android: "Version: 1.1.0 (1)").
            VStack {
                Spacer()
                Text("Version: \(Self.appVersion) (\(Self.buildNumber))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.89))
                    .padding(.bottom, 20)
            }
        }
        .onAppear { startAnimation() }
    }

    private static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }

    private static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
    }

    private var shimmerGradient: LinearGradient {
        let gradient = Gradient(colors: [
            Color(red: 1.0, green: 0.76, blue: 0.89),
            Color(red: 1.0, green: 0.41, blue: 0.71),
            Color(red: 1.0, green: 0.76, blue: 0.89)
        ])
        return LinearGradient(
            gradient: gradient,
            startPoint: UnitPoint(x: shimmerPhase, y: 0),
            endPoint: UnitPoint(x: shimmerPhase + 0.2, y: 1)
        )
    }

    private func startAnimation() {
        withAnimation(.easeOut(duration: 0.8)) {
            offsetX = 0
            offsetY = 0
        }
        withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
            shimmerPhase = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            showFullName = true
            typeText()
        }
    }

    private func typeText() {
        for (index, _) in fullText.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                visibleText = String(fullText.prefix(index + 1))
                if index == fullText.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        onFinished()
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}
