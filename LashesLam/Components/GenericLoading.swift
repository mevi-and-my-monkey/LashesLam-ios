//
//  GenericLoading.swift
//  LashesLam
//
//  Espejo de ui/components/GenericLoading.kt (Android). Overlay de carga a pantalla
//  completa: fondo negro semitransparente + tarjeta blanca con la animación Lottie
//  (misma `loading.json` que Android) y un mensaje opcional.
//

import SwiftUI
import Lottie

/// Wrapper de la animación Lottie para SwiftUI.
struct LottieView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .loop

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)
        view.loopMode = loopMode
        view.contentMode = .scaleAspectFit
        view.play()
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        if !uiView.isAnimationPlaying { uiView.play() }
    }
}

/// Overlay de carga estilo Android. Se muestra solo cuando `isLoading == true`.
struct GenericLoading: View {
    let isLoading: Bool
    var message: String? = nil

    var body: some View {
        if isLoading {
            ZStack {
                Color.black.opacity(0.5).ignoresSafeArea()

                VStack(spacing: 16) {
                    LottieView(name: "loading")
                        .frame(width: 120, height: 120)

                    if let message, !message.isEmpty {
                        Text(message)
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                    }
                }
                .padding(24)
                .background(Color.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(32)
            }
            .transition(.opacity)
        }
    }
}

extension View {
    /// Aplica el overlay `GenericLoading` sobre la vista actual.
    func genericLoading(_ isLoading: Bool, message: String? = nil) -> some View {
        overlay(GenericLoading(isLoading: isLoading, message: message))
    }
}
