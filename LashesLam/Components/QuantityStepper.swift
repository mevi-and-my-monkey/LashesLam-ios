//
//  QuantityStepper.swift
//  LashesLam
//
//  Control +/- de cantidad. Espejo de QuantityStepper en ui/cart/CartScreen.kt.
//

import SwiftUI

struct QuantityStepper: View {
    let quantity: Int
    var onQuantityChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button { onQuantityChange(quantity - 1) } label: {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.darkGrayCompat)
                    .frame(width: 32, height: 32)
            }
            Text("\(quantity)")
                .font(.system(size: 15, weight: .bold))
                .padding(.horizontal, 8)
            Button { onQuantityChange(quantity + 1) } label: {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.darkGrayCompat)
                    .frame(width: 32, height: 32)
            }
        }
        .background(AppColors.pinkPrimary.opacity(0.08))
        .clipShape(Capsule())
    }
}

extension Color {
    static let darkGrayCompat = Color(red: 0.25, green: 0.25, blue: 0.25)
}
