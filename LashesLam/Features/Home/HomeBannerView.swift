//
//  HomeBannerView.swift
//  LashesLam
//
//  Carrusel de banners del Home. Al tocar abre el curso vinculado; el admin puede
//  subir/eliminar banners. Espejo de BannerView.kt de Android.
//

import SwiftUI
import PhotosUI

struct HomeBannerView: View {
    var onOpenCourse: (String) -> Void

    @StateObject private var viewModel = HomeBannerViewModel()
    @ObservedObject private var session = SessionManager.shared

    @State private var currentPage = 0
    @State private var showOptions = false
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 8) {
            if viewModel.urls.isEmpty {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.surfaceVariant)
                    .frame(height: 160)
                    .overlay { LottieView(name: "loading").frame(width: 80, height: 80) }
                    .padding(.horizontal, 16)
            } else {
                TabView(selection: $currentPage) {
                    ForEach(Array(viewModel.urls.enumerated()), id: \.offset) { index, url in
                        AsyncImage(url: URL(string: url)) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFit()
                            } else {
                                ZStack { AppColors.surfaceVariant; LottieView(name: "loading").frame(width: 60, height: 60) }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)
                        .tag(index)
                        .onTapGesture { openCourse(forBanner: index) }
                    }
                }
                .frame(height: 168)
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Indicador de páginas
                HStack(spacing: 6) {
                    ForEach(viewModel.urls.indices, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? AppColors.pinkPrimary : AppColors.pinkPrimary.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }

            if session.isUserAdmin {
                Button("Editar") { showOptions = true }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.pinkPrimary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 16)
            }
        }
        .onAppear { if viewModel.urls.isEmpty { viewModel.load() } }
        .confirmationDialog("Administrar banners", isPresented: $showOptions, titleVisibility: .visible) {
            PhotosPicker("Subir nuevo banner", selection: $pickerItem, matching: .images)
            Button("Eliminar banner actual", role: .destructive) {
                viewModel.deleteBanner(at: currentPage)
            }
            Button("Cancelar", role: .cancel) {}
        }
        .onChange(of: pickerItem) { item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    viewModel.uploadBanner(data)
                }
                pickerItem = nil
            }
        }
        .overlay { GenericLoading(isLoading: viewModel.isLoading) }
    }

    private func openCourse(forBanner index: Int) {
        Task {
            if let id = await viewModel.courseId(forBanner: index) {
                onOpenCourse(id)
            }
        }
    }
}
