//
//  HomeHeaderView.swift
//  LashesLam
//
//  Encabezado del Home con gradiente rosa, igual que HeaderView.kt de Android:
//  foto de perfil + bienvenida + nombre, botón de solicitudes con badge, buscador
//  y menú de secciones con iconos.
//

import SwiftUI

struct HomeHeaderView: View {
    @Binding var section: CatalogSection
    var pendingCount: Int
    var onSearch: () -> Void
    var onRequests: () -> Void

    @ObservedObject private var session = SessionManager.shared

    var body: some View {
        VStack(spacing: 0) {
            // ----- Perfil + botón de solicitudes -----
            HStack(spacing: 8) {
                profilePhoto

                VStack(alignment: .leading, spacing: 0) {
                    Text("¡Bienvenida!")
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.9))
                    Text(session.nameUser ?? "")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }

                Spacer()

                requestsButton
            }

            // ----- Buscador -----
            searchBar
                .padding(.top, 16)

            // ----- Menú de secciones -----
            SectionMenu(selected: $section, onPink: true)
                .padding(.top, 14)
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.50, blue: 0.67),
                         Color(red: 1.0, green: 0.76, blue: 0.89)],
                startPoint: .top, endPoint: .bottom
            )
        )
        .clipShape(RoundedCorners(radius: 24, corners: [.bottomLeft, .bottomRight]))
    }

    private var profilePhoto: some View {
        AsyncImage(url: URL(string: session.photoUrl ?? "")) { phase in
            if let image = phase.image {
                image.resizable().scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable().scaledToFit()
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(Circle())
    }

    private var requestsButton: some View {
        Button(action: onRequests) {
            Image(systemName: "bag")
                .font(.system(size: 18))
                .foregroundColor(.black)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .overlay(alignment: .topTrailing) {
                    if pendingCount > 0 {
                        Text("\(pendingCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(4)
                            .frame(minWidth: 18)
                            .background(session.isUserAdmin ? Color.red : Color(red: 0.13, green: 0.59, blue: 0.95))
                            .clipShape(Circle())
                            .offset(x: 6, y: -6)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var searchBar: some View {
        Button(action: onSearch) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.black)
                Text("Buscar…").foregroundColor(.black.opacity(0.8))
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
