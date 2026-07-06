//
//  CartView.swift
//  LashesLam
//
//  Espejo de ui/cart/CartScreen.kt. Lista del carrito, resumen y checkout por
//  WhatsApp con pantalla de confirmación de orden.
//

import SwiftUI

struct CartView: View {
    @ObservedObject private var cart = CartManager.shared
    @StateObject private var viewModel = CartViewModel()

    private let whatsAppGreen = Color(red: 0.145, green: 0.827, blue: 0.4)
    private let goldAccent = Color(red: 0.69, green: 0.54, blue: 0.24)

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if let order = viewModel.orderPlaced {
                confirmation(order)
            } else {
                VStack(spacing: 0) {
                    header
                    if cart.items.isEmpty {
                        emptyState
                    } else {
                        // LazyVStack en vez de List: dentro de un List los varios
                        // botones de la fila (±/eliminar) se disparan juntos al tocar,
                        // lo que borraba el ítem al aumentar la cantidad.
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(cart.items) { item in
                                    cartRow(item)
                                }
                            }
                            .padding(16)
                        }
                        summary
                    }
                }
            }

            GenericLoading(isLoading: viewModel.isLoading)
        }
        .errorDialog($viewModel.errorMessage)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Mi carrito")
                .font(.appTitle(24))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [Color(red: 1.0, green: 0.50, blue: 0.67),
                                    Color(red: 1.0, green: 0.76, blue: 0.89)],
                           startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedCorners(radius: 24, corners: [.bottomLeft, .bottomRight]))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "cart")
                .font(.system(size: 64))
                .foregroundColor(AppColors.pinkPrimary.opacity(0.4))
            Text("Tu carrito está vacío")
                .font(.headline)
            Text("Agrega productos desde la tienda.")
                .font(.subheadline).foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }

    private func cartRow(_ item: CartItem) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: item.imageUrl)) { phase in
                if let image = phase.image { image.resizable().scaledToFill() }
                else { ZStack { AppColors.pinkPrimary.opacity(0.1); Image(systemName: "photo").foregroundColor(.gray.opacity(0.4)) } }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.appTitleMedium(17)).fontWeight(.bold)
                    .foregroundColor(.black).lineLimit(1)
                if !item.category.isEmpty {
                    Text(item.category).font(.caption).foregroundColor(.gray)
                }
                QuantityStepper(quantity: item.quantity) { newQty in
                    viewModel.updateQuantity(productId: item.productId, quantity: newQty)
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Button { viewModel.removeItem(productId: item.productId) } label: {
                    Image(systemName: "xmark").font(.system(size: 14)).foregroundColor(.gray)
                }
                Spacer()
                Text(Formatters.money(item.price * Double(item.quantity)))
                    .font(.appTitleMedium(17)).fontWeight(.bold)
                    .foregroundColor(AppColors.pinkPrimary)
            }
            .frame(height: 72)
        }
        .padding(12)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }

    // MARK: - Summary

    private var summary: some View {
        VStack(spacing: 12) {
            summaryRow("Subtotal", Formatters.money(cart.subtotal))
            if viewModel.shippingCost > 0 {
                summaryRow("Envío", Formatters.money(viewModel.shippingCost))
            }
            Divider()
            HStack {
                Text("Total").font(.headline).foregroundColor(.black)
                Spacer()
                Text(Formatters.money(cart.subtotal + viewModel.shippingCost))
                    .font(.appTitle(22))
                    .foregroundColor(AppColors.pinkPrimary)
            }

            Button {
                viewModel.finalizeOrder { url in UIApplication.shared.open(url) }
            } label: {
                HStack {
                    Image(systemName: "message.fill")
                    Text("Finalizar pedido por WhatsApp").fontWeight(.bold)
                }
                .frame(maxWidth: .infinity).padding()
                .background(whatsAppGreen).foregroundColor(.white)
                .clipShape(Capsule())
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(AppColors.surface)
        .clipShape(RoundedCorners(radius: 24, corners: [.topLeft, .topRight]))
        .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundColor(.gray)
            Spacer()
            Text(value).fontWeight(.bold).foregroundColor(.black)
        }
        .font(.subheadline)
    }

    // MARK: - Confirmation

    private func confirmation(_ order: ProductOrder) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColors.pinkPrimary)
            Text("¡Gracias por tu compra!")
                .font(.appTitle(28)).foregroundColor(.black)
                .multilineTextAlignment(.center)
            Text("Tu pedido fue enviado. Te contactaremos para confirmarlo.")
                .font(.subheadline).foregroundColor(.gray)
                .multilineTextAlignment(.center)

            HStack {
                Text("RESUMEN").font(.caption.bold()).foregroundColor(goldAccent)
                Spacer()
                Text("#\(order.orderNumber)").font(.subheadline.bold()).foregroundColor(.black)
            }
            .padding().background(AppColors.surface).cornerRadius(16)

            Button { viewModel.resetOrder() } label: {
                Text("Volver").fontWeight(.bold)
                    .frame(maxWidth: .infinity).padding()
                    .background(Color(red: 0.11, green: 0.11, blue: 0.11))
                    .foregroundColor(.white).clipShape(Capsule())
            }
            Spacer()
        }
        .padding(24)
    }
}

/// Recortes de esquinas específicas (para headers/summary redondeados).
struct RoundedCorners: Shape {
    var radius: CGFloat = 16
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
