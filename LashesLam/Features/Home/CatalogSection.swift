//
//  CatalogSection.swift
//  LashesLam
//
//  Secciones del catálogo (Cursos / Productos / Servicios) y el menú de secciones
//  con iconos, igual que HeaderCategoriesMenu.kt de Android. Reutilizado por el
//  header del Home y por la búsqueda.
//

import SwiftUI

enum CatalogSection: String, CaseIterable, Identifiable {
    case cursos
    case productos
    case servicios

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cursos: return "Cursos"
        case .productos: return "Productos"
        case .servicios: return "Servicios"
        }
    }

    /// Icono circular (mismos assets que ic_courses/ic_products/ic_services de Android).
    var iconName: String {
        switch self {
        case .cursos: return "ic_courses"
        case .productos: return "ic_products"
        case .servicios: return "ic_services"
        }
    }
}

/// Menú horizontal de secciones con icono + etiqueta. `onPink` ajusta los colores
/// del texto según el fondo (header rosa vs. búsqueda con fondo claro).
struct SectionMenu: View {
    @Binding var selected: CatalogSection
    var onPink: Bool = true
    var onSelect: ((CatalogSection) -> Void)? = nil

    var body: some View {
        HStack {
            ForEach(CatalogSection.allCases) { section in
                let isSelected = section == selected
                VStack(spacing: 2) {
                    Image(section.iconName)
                        .resizable().scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                    Text(section.title)
                        .font(.system(size: 13, weight: isSelected ? .bold : .regular))
                        .foregroundColor(labelColor(isSelected))
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    selected = section
                    onSelect?(section)
                }
            }
        }
        .padding(.top, 6)
    }

    private func labelColor(_ isSelected: Bool) -> Color {
        if onPink {
            return isSelected ? .white : Color.black.opacity(0.6)
        } else {
            return isSelected ? AppColors.pinkPrimary : .gray
        }
    }
}
