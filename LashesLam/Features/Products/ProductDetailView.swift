//
//  ProductDetailView.swift
//  LashesLam
//
//  Detalle de producto: carrusel de imágenes, más vendido, precios, características,
//  descripción y contacto (WhatsApp/Instagram/Facebook). Espejo de
//  ui/products/details/ProductDetailContent.kt.
//

import SwiftUI

struct ProductDetailView: View {
    let product: ProductItem
    @EnvironmentObject var session: SessionManager
    @ObservedObject private var cart = CartManager.shared

    @State private var quantity = 1
    @State private var addedToCart = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                imageCarousel

                VStack(alignment: .leading, spacing: 12) {
                    if product.bestSelling {
                        Label("Lo más vendido", systemImage: "star.fill")
                            .font(.footnote.bold())
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(AppColors.pinkTertiary)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                    }

                    Text(product.title)
                        .font(.appTitle(26))
                        .foregroundColor(AppColors.onSurface)

                    if !product.characteristics.isEmpty {
                        Text(product.characteristics)
                            .font(.subheadline)
                            .foregroundColor(AppColors.onSurfaceVariant)
                    }

                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(Formatters.money(product.actualPrice))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.pinkPrimary)
                        if product.price != 0.0 {
                            Text(Formatters.money(product.price))
                                .font(.system(size: 16))
                                .strikethrough()
                                .foregroundColor(.gray)
                        }
                    }

                    // Agregar al carrito (oculto para administradores).
                    if !session.isUserAdmin {
                        addToCartSection
                    }

                    if !product.description.isEmpty {
                        Text("Descripción")
                            .font(.headline)
                            .padding(.top, 8)
                        Text(product.description)
                            .font(.body)
                            .foregroundColor(AppColors.onSurfaceVariant)
                    }

                    Divider().padding(.vertical, 8)

                    Text("¿Te interesa? Solicita más información")
                        .font(.subheadline.bold())
                    contactButtons
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 32)
        }
        .background(AppColors.surface.ignoresSafeArea())
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteHeartButton(itemId: product.id, type: .product, bare: true)
            }
        }
    }

    private var addToCartSection: some View {
        HStack(spacing: 12) {
            QuantityStepper(quantity: quantity) { newQty in
                if newQty >= 1 { quantity = newQty }
            }
            Button {
                cart.addItem(CartItem(
                    productId: product.id,
                    title: product.title,
                    category: product.category,
                    imageUrl: product.images.first ?? "",
                    price: product.actualPrice,
                    quantity: quantity
                ))
                quantity = 1
                addedToCart = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { addedToCart = false }
            } label: {
                HStack {
                    Image(systemName: "cart.fill")
                    Text(addedToCart ? "¡Agregado!" : "Agregar al carrito").fontWeight(.bold)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(addedToCart ? Color(red: 0.30, green: 0.44, blue: 0.27) : AppColors.pinkPrimary)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .padding(.vertical, 8)
    }

    private var imageCarousel: some View {
        TabView {
            ForEach(Array(product.images.enumerated()), id: \.offset) { _, url in
                AsyncImage(url: URL(string: url)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else {
                        ZStack { AppColors.surfaceVariant; ProgressView() }
                    }
                }
            }
            if product.images.isEmpty {
                ZStack { AppColors.surfaceVariant; Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray) }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 300)
        .background(AppColors.surfaceVariant)
    }

    private var contactButtons: some View {
        HStack(spacing: 16) {
            if let whatsapp = session.whatsApp, !whatsapp.isEmpty {
                contactButton(icon: "message.fill", color: Color(red: 0.15, green: 0.83, blue: 0.45)) {
                    let url = Formatters.whatsAppProductURL(
                        title: product.title,
                        price: Formatters.money(product.actualPrice),
                        whatsapp: whatsapp
                    )
                    open(url)
                }
            }
            if let instagram = session.instagram, !instagram.isEmpty {
                contactButton(icon: "camera.fill", color: Color(red: 0.76, green: 0.23, blue: 0.55)) {
                    open(URL(string: instagram))
                }
            }
            if let facebook = session.facebook, !facebook.isEmpty {
                contactButton(icon: "f.circle.fill", color: Color(red: 0.23, green: 0.35, blue: 0.6)) {
                    open(URL(string: facebook))
                }
            }
        }
    }

    private func contactButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.white)
                .frame(width: 52, height: 52)
                .background(color)
                .clipShape(Circle())
        }
    }

    private func open(_ url: URL?) {
        guard let url else { return }
        UIApplication.shared.open(url)
    }
}
