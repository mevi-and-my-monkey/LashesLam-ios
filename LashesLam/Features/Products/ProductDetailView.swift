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
    @Environment(\.dismiss) private var dismiss

    @State private var quantity = 1
    @State private var addedToCart = false
    @State private var showEditForm = false
    @State private var showDeleteConfirm = false
    @State private var isDeleting = false
    private let productsRepository = ProductsRepository()

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

                    priceRow

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
                    SocialMediaRow(
                        whatsAppURL: whatsAppURL,
                        instagram: session.instagram,
                        facebook: session.facebook
                    )
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
                if session.isUserAdmin {
                    Menu {
                        Button { showEditForm = true } label: { Label("Editar", systemImage: "pencil") }
                        Button(role: .destructive) { showDeleteConfirm = true } label: { Label("Eliminar", systemImage: "trash") }
                    } label: { Image(systemName: "ellipsis.circle") }
                } else {
                    FavoriteHeartButton(itemId: product.id, type: .product, bare: true)
                }
            }
        }
        .sheet(isPresented: $showEditForm) { ProductFormView(product: product) }
        .confirmationDialog("¿Eliminar este producto?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Eliminar", role: .destructive) { deleteProduct() }
            Button("Cancelar", role: .cancel) {}
        }
        .overlay { GenericLoading(isLoading: isDeleting) }
    }

    private func deleteProduct() {
        Task {
            isDeleting = true
            let result = await productsRepository.deleteProduct(id: product.id, imageUrls: product.images)
            isDeleting = false
            if case .success = result {
                NotificationCenter.default.post(name: .catalogDidChange, object: nil)
                dismiss()
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

    // MARK: - Precio (igual que DetailCostProductView.kt: precio actual grande y,
    // solo si hay descuento real, el precio original tachado + % de descuento).

    private var priceRow: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(Formatters.money(product.actualPrice))
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(AppColors.pinkPrimary)

            if product.price > product.actualPrice {
                Text(Formatters.money(product.price))
                    .font(.system(size: 16))
                    .strikethrough()
                    .foregroundColor(.gray)

                Text("-\(discountPercent)%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.pinkPrimary)
                    .padding(.horizontal, 8).padding(.vertical, 2)
                    .background(Color(red: 0.99, green: 0.95, blue: 0.94))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppColors.pinkPrimary.opacity(0.3), lineWidth: 0.5))
            }
        }
    }

    private var discountPercent: Int {
        guard product.price > product.actualPrice, product.price > 0 else { return 0 }
        return Int(((product.price - product.actualPrice) / product.price) * 100)
    }

    private var whatsAppURL: URL? {
        guard let whatsapp = session.whatsApp, !whatsapp.isEmpty else { return nil }
        return Formatters.whatsAppProductURL(
            title: product.title,
            price: Formatters.money(product.actualPrice),
            whatsapp: whatsapp
        )
    }
}
