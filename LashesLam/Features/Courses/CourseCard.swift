//
//  CourseCard.swift
//  LashesLam
//
//  Tarjeta de curso (imagen grande + título, fecha, horario y costo).
//

import SwiftUI

struct CourseCard: View {
    let course: CourseItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: course.imagen)) { phase in
                if let image = phase.image { image.resizable().scaledToFill() }
                else { ZStack { AppColors.surfaceVariant; Image(systemName: "graduationcap").foregroundColor(.gray.opacity(0.4)) } }
            }
            .frame(height: 150).frame(maxWidth: .infinity).clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(course.titulo)
                    .font(.appTitleMedium(19)).fontWeight(.bold)
                    .foregroundColor(AppColors.onSurface)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    Label(course.fecha, systemImage: "calendar")
                    Label(course.schedule, systemImage: "clock")
                }
                .font(.caption).foregroundColor(.gray)

                Text(Formatters.money(course.costo))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.pinkPrimary)
                    .padding(.top, 2)
            }
            .padding(14)
        }
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.07), radius: 6, y: 3)
    }
}
