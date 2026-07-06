//
//  FavoriteProductCard.swift
//  LashesLam
//
//  Tarjeta de producto favorito, espejo de FavoriteProductCard.kt: imagen, badge
//  "más vendido", título, características, chevron y precio.
//

import SwiftUI

struct FavoriteProductCard: View {
    let product: ProductItem

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: product.images.first ?? "")) { phase in
                if let image = phase.image { image.resizable().scaledToFill() }
                else { ZStack { Color(red: 0.99, green: 0.95, blue: 0.94); Image(systemName: "photo").foregroundColor(.gray.opacity(0.4)) } }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                if product.bestSelling {
                    Text("MÁS VENDIDO")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(red: 0.76, green: 0.60, blue: 0.42))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color(red: 0.99, green: 0.95, blue: 0.94))
                        .clipShape(Capsule())
                }
                Text(product.title)
                    .font(.appTitleMedium(18)).fontWeight(.bold)
                    .foregroundColor(AppColors.onSurface)
                    .lineLimit(2)
                if !product.characteristics.isEmpty {
                    Text(product.characteristics)
                        .font(.caption).foregroundColor(.gray)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Image(systemName: "chevron.right").font(.system(size: 16)).foregroundColor(.gray.opacity(0.5))
                Spacer()
                Text(Formatters.money(product.actualPrice))
                    .font(.appTitleMedium(20)).fontWeight(.bold)
                    .foregroundColor(AppColors.pinkPrimary)
            }
            .frame(height: 80)
        }
        .padding(12)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}
