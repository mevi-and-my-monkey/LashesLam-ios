//
//  ProfilePageView.swift
//  LashesLam
//
//  Espejo de ui/profile/ProfilePage.kt. Header con foto + datos del usuario,
//  opciones de cuenta, modo oscuro y cierre de sesión.
//

import SwiftUI
import PhotosUI

struct ProfilePageView: View {
    var onLogout: () -> Void

    @EnvironmentObject var session: SessionManager
    @StateObject private var viewModel = ProfileViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false

    @State private var photoItem: PhotosPickerItem?
    @State private var showEditAddress = false
    @State private var showEditPhone = false
    @State private var showLogoutConfirm = false
    @State private var showRequests = false
    @State private var showFavorites = false

    var body: some View {
        NavigationStack {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header
                    accountSection
                }
            }

            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView().tint(AppColors.pinkPrimary)
                }
            }
        }
        .navigationDestination(isPresented: $showRequests) {
            RequestsView(isAdmin: session.isUserAdmin)
        }
        .navigationDestination(isPresented: $showFavorites) {
            FavoritesView()
        }
        .onAppear { viewModel.loadUserData() }
        .sheet(isPresented: $showEditAddress) {
            EditAddressSheet { address in viewModel.updateAddress(address) }
        }
        .sheet(isPresented: $showEditPhone) {
            EditPhoneSheet(currentPhone: viewModel.user.phone) { phone in viewModel.updatePhone(phone) }
        }
        .onChange(of: photoItem) { item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    viewModel.updateProfilePhoto(data: data)
                }
            }
        }
        .alert("Listo", isPresented: Binding(
            get: { viewModel.successMessage != nil },
            set: { if !$0 { viewModel.successMessage = nil } })
        ) {
            Button("OK", role: .cancel) { viewModel.successMessage = nil }
        } message: { Text(viewModel.successMessage ?? "") }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } })
        ) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "") }
        .confirmationDialog("¿Estás segura que quieres cerrar sesión?",
                            isPresented: $showLogoutConfirm, titleVisibility: .visible) {
            Button("Cerrar sesión", role: .destructive) {
                viewModel.signOut()
                onLogout()
            }
            Button("Cancelar", role: .cancel) {}
        }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: viewModel.photoUser)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable().scaledToFit()
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .frame(width: 120, height: 120)
                .background(Color.white)
                .clipShape(Circle())

                PhotosPicker(selection: $photoItem, matching: .images) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(AppColors.pinkPrimary)
                        .clipShape(Circle())
                }
            }

            Text(viewModel.user.name ?? "Usuario")
                .font(.appTitle(26))
                .foregroundColor(.black)

            Text(viewModel.user.email ?? session.emailUser ?? "")
                .font(.system(size: 14))
                .foregroundColor(.black)
                .padding(.horizontal, 16).padding(.vertical, 6)
                .background(Color.white.opacity(0.25))
                .cornerRadius(12)

            Text("Teléfono: \(valueOrDefault(viewModel.user.phone))")
                .font(.system(size: 14)).foregroundColor(.black)

            Text("Dirección: \(valueOrDefault(viewModel.user.address))")
                .font(.system(size: 14)).foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.50, blue: 0.67),
                         Color(red: 1.0, green: 0.76, blue: 0.89)],
                startPoint: .top, endPoint: .bottom
            )
        )
    }

    // MARK: - Sección de cuenta

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Modo oscuro
            HStack {
                Image(systemName: "moon.fill").foregroundColor(AppColors.pinkPrimary)
                Text("Modo oscuro").font(.system(size: 18))
                Spacer()
                Toggle("", isOn: $isDarkMode).labelsHidden().tint(AppColors.pinkPrimary)
            }
            .padding(.vertical, 8)

            Text("Cuenta")
                .font(.appTitleMedium(22)).fontWeight(.bold)
                .foregroundColor(AppColors.onBackground)
                .padding(.top, 8)

            ProfileOptionButton(systemIcon: "mappin.and.ellipse", text: "Editar dirección") {
                showEditAddress = true
            }
            ProfileOptionButton(systemIcon: "phone.fill", text: "Editar teléfono") {
                showEditPhone = true
            }
            if !session.isUserAdmin {
                ProfileOptionButton(systemIcon: "heart.fill", text: "Favoritos") {
                    showFavorites = true
                }
            }
            ProfileOptionButton(systemIcon: "bag.fill",
                                text: session.isUserAdmin ? "Solicitudes" : "Pedidos y solicitudes") {
                showRequests = true
            }

            Button(role: .destructive) {
                showLogoutConfirm = true
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Cerrar sesión").fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.pinkPrimary)
                .foregroundColor(AppColors.onPrimary)
                .cornerRadius(12)
            }
            .padding(.top, 12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private func valueOrDefault(_ value: String?) -> String {
        let v = value?.trimmingCharacters(in: .whitespaces) ?? ""
        return v.isEmpty ? "Sin datos registrados" : v
    }
}
