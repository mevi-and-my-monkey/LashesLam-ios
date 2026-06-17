//
//  PrimaryButton.swift
//  LashesLam
//
//  Created by Alejandro Mejia v on 18/10/25.
//

import Foundation
import SwiftUI


struct PrimaryButton: View {
    
    var text: String
    var icon: Image? = nil
    var backgroundColor: Color = AppColors.pinkPrimary
    var textColor: Color = AppColors.onPrimary
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    icon
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                Text(text)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
        }
    }
}

struct OutlinedButton: View {
    var text: String
    var icon: Image? = nil
    var textColor: Color = AppColors.onSecondary
    var borderColor: Color = AppColors.outline
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    icon
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                Text(text)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
            .cornerRadius(12)
        }
    }
}
