//
//  ReservationCard.swift
//  LashesLam
//
//  Tarjeta de cita, compartida entre usuario y admin (con acciones de estado).
//

import SwiftUI

struct ReservationCard: View {
    let reservation: ServiceReservation
    var isAdmin: Bool = false
    var onAccept: (() -> Void)?
    var onReject: (() -> Void)?
    var onArchive: (() -> Void)?

    private var style: (color: Color, background: Color, label: String) {
        switch reservation.status {
        case BookingRepository.Status.scheduled:
            return (Color(red: 0.30, green: 0.44, blue: 0.27), Color(red: 0.91, green: 0.94, blue: 0.90), "Agendado")
        case BookingRepository.Status.cancelled:
            return (Color(red: 0.80, green: 0.25, blue: 0.25), Color(red: 0.98, green: 0.91, blue: 0.91), "Cancelado")
        case BookingRepository.Status.archived:
            return (Color(red: 0.36, green: 0.36, blue: 0.36), Color(red: 0.93, green: 0.93, blue: 0.93), "Archivado")
        default:
            return (Color(red: 0.55, green: 0.45, blue: 0.33), Color(red: 0.98, green: 0.95, blue: 0.91), "Pendiente")
        }
    }

    private var isPending: Bool { reservation.status == BookingRepository.Status.pending }

    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(style.color).frame(width: 5)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text("#\(reservation.reservationNumber)")
                        .font(.appTitleMedium(18)).fontWeight(.bold)
                        .foregroundColor(AppColors.pinkPrimary)
                    Spacer()
                    Text(Formatters.money(reservation.price))
                        .font(.appTitle(22)).foregroundColor(AppColors.onSurface)
                }

                Text(reservation.serviceName)
                    .font(.subheadline.bold()).foregroundColor(AppColors.onSurface)

                Label("\(reservation.dateLabel) · \(reservation.time)", systemImage: "calendar")
                    .font(.caption).foregroundColor(.gray)

                if !reservation.durationLabel.isEmpty {
                    Label(reservation.durationLabel, systemImage: "clock")
                        .font(.caption).foregroundColor(.gray)
                }

                if isAdmin, !reservation.nameUser.isEmpty {
                    Text(reservation.nameUser).font(.caption).foregroundColor(.gray)
                }

                Divider()
                HStack { statusPill; Spacer() }

                if isAdmin { adminActions }
            }
            .padding(16)
        }
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
        .padding(.horizontal, 16).padding(.vertical, 8)
    }

    private var statusPill: some View {
        HStack(spacing: 8) {
            Circle().fill(style.color).frame(width: 6, height: 6)
            Text(style.label).font(.caption.bold()).foregroundColor(style.color)
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(style.background).clipShape(Capsule())
    }

    @ViewBuilder
    private var adminActions: some View {
        if isPending {
            HStack(spacing: 10) {
                actionButton("Aceptar", Color(red: 0.30, green: 0.44, blue: 0.27)) { onAccept?() }
                actionButton("Rechazar", Color(red: 0.80, green: 0.25, blue: 0.25)) { onReject?() }
            }
            .padding(.top, 4)
        } else if reservation.status != BookingRepository.Status.archived {
            actionButton("Archivar", Color(red: 0.36, green: 0.36, blue: 0.36)) { onArchive?() }
                .padding(.top, 4)
        }
    }

    private func actionButton(_ title: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.subheadline.bold())
                .frame(maxWidth: .infinity).padding(.vertical, 8)
                .background(color).foregroundColor(.white).clipShape(Capsule())
        }
    }
}
