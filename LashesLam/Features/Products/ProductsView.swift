//
//  ProductsView.swift
//  LashesLam
//
//  Contenido del catálogo de productos (chips de categoría, "Lo más vendido" y
//  cuadrícula). Se embebe dentro del Home con selector de secciones, por lo que
//  no incluye su propio NavigationStack.
//

import SwiftUI

struct ProductsView: View {
    @StateObject private var viewModel = ProductsViewModel()

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                categoryChips

                if !viewModel.bestSellingProducts.isEmpty {
                    Text("Lo más vendido")
                        .font(.appTitleMedium(22)).fontWeight(.bold)
                        .foregroundColor(AppColors.onBackground)
                        .padding(.horizontal, 16)
                    bestSellingRow
                }

                HStack {
                    Text("Productos")
                        .font(.appTitleMedium(22)).fontWeight(.bold)
                        .foregroundColor(AppColors.onBackground)
                    Spacer()
                    Text("\(viewModel.filteredProducts.count) productos")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.pinkPrimary)
                }
                .padding(.horizontal, 16)

                grid
            }
            .padding(.vertical, 8)
        }
        .background(AppColors.background.ignoresSafeArea())
        .overlay {
            if viewModel.isLoading {
                ProgressView().tint(AppColors.pinkPrimary)
            } else if viewModel.filteredProducts.isEmpty && viewModel.bestSellingProducts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bag").font(.system(size: 44)).foregroundColor(.gray.opacity(0.5))
                    Text("Sin productos").font(.headline)
                    Text("Aún no hay productos disponibles.").font(.subheadline).foregroundColor(.gray)
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } })
        ) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "") }
        .onAppear { if viewModel.products.isEmpty { viewModel.load() } }
        .refreshable { viewModel.load() }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.categories) { category in
                    let selected = category.id == viewModel.selectedCategoryId
                    Text(category.name)
                        .font(.system(size: 14, weight: selected ? .semibold : .regular))
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(selected ? AppColors.onSurface : AppColors.surface)
                        .foregroundColor(selected ? AppColors.onPrimary : AppColors.onSurfaceVariant)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppColors.outline.opacity(0.4), lineWidth: selected ? 0 : 1))
                        .onTapGesture { viewModel.selectCategory(category) }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var bestSellingRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.bestSellingProducts) { product in
                    NavigationLink {
                        ProductDetailView(product: product)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            AsyncImage(url: URL(string: product.images.first ?? "")) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill()
                                } else {
                                    ZStack { AppColors.surfaceVariant; Image(systemName: "photo").foregroundColor(.gray.opacity(0.4)) }
                                }
                            }
                            .frame(width: 100, height: 100)
                            .clipped().cornerRadius(10)

                            Text(product.title)
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.onSurface)
                                .lineLimit(1).frame(width: 100, alignment: .leading)
                            Text(Formatters.money(product.actualPrice))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.pinkPrimary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.filteredProducts) { product in
                ZStack(alignment: .topTrailing) {
                    NavigationLink {
                        ProductDetailView(product: product)
                    } label: {
                        ProductCard(product: product)
                    }
                    .buttonStyle(.plain)
                    FavoriteHeartButton(itemId: product.id, type: .product).padding(18)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
