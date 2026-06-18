//
//  ProductCard.swift
//  LashesLam
//
//  Tarjeta de producto para la cuadrícula de la tienda. Espejo de
//  ui/home/products/components/ProductsItem.kt.
//

import SwiftUI

struct ProductCard: View {
    let product: ProductItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: product.images.first ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    ZStack {
                        AppColors.surfaceVariant
                        Image(systemName: "photo")
                            .foregroundColor(.gray.opacity(0.4))
                    }
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .clipped()
            .cornerRadius(10)

            Text(product.title)
                .font(.appTitleMedium(18))
                .foregroundColor(AppColors.onSurface)
                .lineLimit(1)

            if product.price != 0.0 {
                Text(Formatters.money(product.price))
                    .font(.system(size: 13))
                    .strikethrough()
                    .foregroundColor(.gray)
            }

            Text(Formatters.money(product.actualPrice))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColors.pinkPrimary)
        }
        .padding(12)
        .background(AppColors.surface)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }
}
