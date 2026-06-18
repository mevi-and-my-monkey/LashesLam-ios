//
//  ProfileOptionButton.swift
//  LashesLam
//
//  Fila de opción del perfil (icono + texto + chevron). Equivalente a
//  ui/components/ProfileOptionButton de Android, con SF Symbols.
//

import SwiftUI

struct ProfileOptionButton: View {
    let systemIcon: String
    let text: String
    var onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 16) {
                Image(systemName: systemIcon)
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.pinkPrimary)
                    .frame(width: 24)
                Text(text)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.onSurface)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(AppColors.surface)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
