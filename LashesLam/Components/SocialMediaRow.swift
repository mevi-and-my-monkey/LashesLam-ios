//
//  SocialMediaRow.swift
//  LashesLam
//
//  Fila de botones de redes sociales (Facebook, Instagram, WhatsApp) para pedir
//  más información. Espejo de DetailsSocialMediaView de Android, con iconos de marca.
//

import SwiftUI

struct SocialMediaRow: View {
    /// URL de WhatsApp ya construida con el mensaje del producto/curso/servicio.
    var whatsAppURL: URL?
    var instagram: String?
    var facebook: String?

    var body: some View {
        HStack(spacing: 20) {
            if let facebook, !facebook.isEmpty {
                socialButton(asset: "ic_facebook") { open(URL(string: facebook)) }
            }
            if let instagram, !instagram.isEmpty {
                socialButton(asset: "ic_instagram") { open(URL(string: instagram)) }
            }
            if let whatsAppURL {
                socialButton(asset: "ic_whatsapp") { open(whatsAppURL) }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func socialButton(asset: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(asset)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .padding(11)
                .background(AppColors.pinkPrimary)
                .clipShape(Circle())
        }
    }

    private func open(_ url: URL?) {
        guard let url else { return }
        UIApplication.shared.open(url)
    }
}
