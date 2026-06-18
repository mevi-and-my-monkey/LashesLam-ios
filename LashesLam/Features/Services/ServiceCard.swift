//
//  ServiceCard.swift
//  LashesLam
//
//  Tarjeta de servicio (imagen + título + subtítulo + duración + precio).
//

import SwiftUI

struct ServiceCard: View {
    let service: ServiceItem

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: service.image)) { phase in
                if let image = phase.image { image.resizable().scaledToFill() }
                else { ZStack { AppColors.surfaceVariant; Image(systemName: "sparkles").foregroundColor(.gray.opacity(0.4)) } }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text(service.title)
                    .font(.appTitleMedium(18)).fontWeight(.bold)
                    .foregroundColor(AppColors.onSurface)
                    .lineLimit(1)
                if !service.subtitle.isEmpty {
                    Text(service.subtitle)
                        .font(.caption).foregroundColor(.gray)
                        .lineLimit(2)
                }
                HStack(spacing: 12) {
                    Label(Formatters.serviceDuration(service.duration), systemImage: "clock")
                        .font(.caption2).foregroundColor(AppColors.onSurfaceVariant)
                    Text(Formatters.money(service.price))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.pinkPrimary)
                }
                .padding(.top, 2)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray.opacity(0.5))
        }
        .padding(12)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 5, y: 2)
    }
}
