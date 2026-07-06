//
//  FavoriteCourseCard.swift
//  LashesLam
//
//  Tarjeta de curso favorito, espejo de FavoriteCourseCard.kt: título en mayúsculas,
//  costo/fecha/horario con iconos y botón "Ver detalles".
//

import SwiftUI

struct FavoriteCourseCard: View {
    let course: CourseItem

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(course.titulo.uppercased())
                    .font(.appTitleMedium(18)).fontWeight(.bold)
                    .foregroundColor(AppColors.pinkPrimary)

                infoRow(icon: "dollarsign.circle", text: "Costo: \(Formatters.money(course.costo))")
                infoRow(icon: "calendar", text: "Fecha: \(course.fecha)")
                infoRow(icon: "clock", text: "Horario: \(course.horaInicio) - \(course.horaFin)")
            }

            Spacer()

            Text("Ver detalles")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(AppColors.pinkPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 16).padding(.vertical, 20)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.pinkPrimary.opacity(0.2), lineWidth: 1)
        )
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(.gray)
            Text(text).font(.subheadline).foregroundColor(.gray)
        }
    }
}
