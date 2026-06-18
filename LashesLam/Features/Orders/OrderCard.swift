//
//  OrderCard.swift
//  LashesLam
//
//  Tarjeta de orden compartida entre la vista de usuario y la de admin.
//  Espejo de RequestUserProductItem / el item admin de AdmRequestProductsScreen.
//

import SwiftUI

struct OrderStatusStyle {
    let color: Color
    let background: Color
    let label: String

    static func from(_ status: String) -> OrderStatusStyle {
        switch status {
        case ProductOrderRepository.Status.completed, ProductOrderRepository.Status.legacyAccepted:
            return .init(color: Color(red: 0.30, green: 0.44, blue: 0.27),
                         background: Color(red: 0.91, green: 0.94, blue: 0.90), label: "Completado")
        case ProductOrderRepository.Status.archived:
            return .init(color: Color(red: 0.36, green: 0.36, blue: 0.36),
                         background: Color(red: 0.93, green: 0.93, blue: 0.93), label: "Archivado")
        default:
            return .init(color: Color(red: 0.55, green: 0.45, blue: 0.33),
                         background: Color(red: 0.98, green: 0.95, blue: 0.91), label: "Pendiente")
        }
    }
}

struct OrderCard: View {
    let order: ProductOrder
    var isAdmin: Bool = false
    var onComplete: (() -> Void)?
    var onArchive: (() -> Void)?

    private var style: OrderStatusStyle { .from(order.status) }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()

    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(style.color).frame(width: 5)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text("#\(order.orderNumber)")
                        .font(.appTitleMedium(18)).fontWeight(.bold)
                        .foregroundColor(AppColors.pinkPrimary)
                    Spacer()
                    Text(Formatters.money(order.total))
                        .font(.appTitle(22))
                        .foregroundColor(AppColors.onSurface)
                }

                Label(Self.dateFormatter.string(from: order.date), systemImage: "calendar")
                    .font(.caption).foregroundColor(.gray)

                if isAdmin, !order.nameUser.isEmpty {
                    Text(order.nameUser).font(.caption).foregroundColor(.gray)
                }

                ForEach(order.items) { item in
                    Text("• \(item.quantity) x \(item.title)")
                        .font(.system(size: 13)).foregroundColor(.gray)
                }

                Divider()

                HStack {
                    statusPill
                    Spacer()
                }

                if isAdmin && order.status == ProductOrderRepository.Status.pending {
                    HStack(spacing: 10) {
                        Button { onComplete?() } label: {
                            Text("Completar").font(.subheadline.bold())
                                .frame(maxWidth: .infinity).padding(.vertical, 8)
                                .background(Color(red: 0.30, green: 0.44, blue: 0.27))
                                .foregroundColor(.white).clipShape(Capsule())
                        }
                        Button { onArchive?() } label: {
                            Text("Archivar").font(.subheadline.bold())
                                .frame(maxWidth: .infinity).padding(.vertical, 8)
                                .background(Color(red: 0.36, green: 0.36, blue: 0.36))
                                .foregroundColor(.white).clipShape(Capsule())
                        }
                    }
                    .padding(.top, 4)
                }
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
            Text(style.label)
                .font(.caption.bold())
                .foregroundColor(style.color)
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(style.background)
        .clipShape(Capsule())
    }
}
