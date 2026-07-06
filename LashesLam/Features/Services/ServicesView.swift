//
//  ServicesView.swift
//  LashesLam
//
//  Contenido del catálogo de servicios. Se embebe en el Home con selector de
//  secciones, por lo que no incluye su propio NavigationStack.
//

import SwiftUI

struct ServicesView: View {
    @StateObject private var viewModel = ServicesViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                categoryChips
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredServices) { service in
                        ZStack(alignment: .topTrailing) {
                            NavigationLink {
                                ServiceDetailView(service: service)
                            } label: {
                                ServiceCard(service: service)
                            }
                            .buttonStyle(.plain)
                            FavoriteHeartButton(itemId: service.id, type: .service)
                                .padding(10)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
        }
        .background(AppColors.background.ignoresSafeArea())
        .overlay {
            if viewModel.isLoading {
                LottieView(name: "loading").frame(width: 100, height: 100)
            } else if viewModel.filteredServices.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles").font(.system(size: 44)).foregroundColor(.gray.opacity(0.5))
                    Text("Sin servicios").font(.headline)
                    Text("Aún no hay servicios disponibles.").font(.subheadline).foregroundColor(.gray)
                }
            }
        }
        .errorDialog($viewModel.errorMessage)
        .onAppear { if viewModel.services.isEmpty { viewModel.load() } }
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
}
