//
//  ServiceDetailView.swift
//  LashesLam
//
//  Detalle de servicio: imagen, datos, qué incluye, descripción y botón de
//  agendar cita. Espejo de ui/services/details.
//

import SwiftUI

struct ServiceDetailView: View {
    let service: ServiceItem
    @EnvironmentObject var session: SessionManager
    @Environment(\.dismiss) private var dismiss

    @State private var showEditForm = false
    @State private var showDeleteConfirm = false
    @State private var isDeleting = false
    private let servicesRepository = ServicesRepository()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Contenedor de altura fija que recorta la imagen: evita que
                // scaledToFill desborde y "expanda" la vista ocultando elementos.
                Color.clear
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                    .overlay {
                        AsyncImage(url: URL(string: service.image)) { phase in
                            if let image = phase.image { image.resizable().scaledToFill() }
                            else { ZStack { AppColors.surfaceVariant; LottieView(name: "loading").frame(width: 60, height: 60) } }
                        }
                    }
                    .clipped()

                VStack(alignment: .leading, spacing: 12) {
                    Text(service.title).font(.appTitle(26)).foregroundColor(AppColors.onSurface)
                    if !service.subtitle.isEmpty {
                        Text(service.subtitle).font(.subheadline).foregroundColor(AppColors.onSurfaceVariant)
                    }

                    HStack(spacing: 16) {
                        Label(Formatters.serviceDuration(service.duration), systemImage: "clock")
                            .font(.subheadline).foregroundColor(AppColors.onSurfaceVariant)
                        Text(Formatters.money(service.price))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppColors.pinkPrimary)
                    }

                    if !service.includes.isEmpty {
                        Text("Incluye").font(.headline).padding(.top, 4)
                        ForEach(service.includes, id: \.self) { item in
                            Label(item, systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(AppColors.onSurfaceVariant)
                        }
                    }

                    if !service.description.isEmpty {
                        Text("Descripción").font(.headline).padding(.top, 4)
                        Text(service.description).font(.body).foregroundColor(AppColors.onSurfaceVariant)
                    }

                    // El agendado/contacto solo para usuarios (no admin), igual que Android.
                    if !session.isUserAdmin {
                        NavigationLink {
                            BookingView(service: service)
                        } label: {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("Agendar cita").fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity).padding()
                            .background(AppColors.pinkPrimary).foregroundColor(.white)
                            .clipShape(Capsule())
                        }
                        .padding(.top, 8)

                        if let whatsapp = session.whatsApp, !whatsapp.isEmpty {
                            Button {
                                let url = Formatters.whatsAppProductURL(
                                    title: service.title,
                                    price: Formatters.money(service.price),
                                    whatsapp: whatsapp
                                )
                                if let url { UIApplication.shared.open(url) }
                            } label: {
                                HStack {
                                    Image(systemName: "message.fill")
                                    Text("Más información por WhatsApp").fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity).padding()
                                .background(Color(red: 0.145, green: 0.827, blue: 0.4).opacity(0.15))
                                .foregroundColor(Color(red: 0.10, green: 0.55, blue: 0.30))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 32)
        }
        .background(AppColors.surface.ignoresSafeArea())
        .navigationTitle(service.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if session.isUserAdmin {
                    Menu {
                        Button { showEditForm = true } label: { Label("Editar", systemImage: "pencil") }
                        Button(role: .destructive) { showDeleteConfirm = true } label: { Label("Eliminar", systemImage: "trash") }
                    } label: { Image(systemName: "ellipsis.circle") }
                } else {
                    FavoriteHeartButton(itemId: service.id, type: .service, bare: true)
                }
            }
        }
        .sheet(isPresented: $showEditForm) { ServiceFormView(service: service) }
        .confirmationDialog("¿Eliminar este servicio?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Eliminar", role: .destructive) { deleteService() }
            Button("Cancelar", role: .cancel) {}
        }
        .overlay { GenericLoading(isLoading: isDeleting) }
    }

    private func deleteService() {
        Task {
            isDeleting = true
            let result = await servicesRepository.deleteService(id: service.id, imageUrl: service.image)
            isDeleting = false
            if case .success = result {
                NotificationCenter.default.post(name: .catalogDidChange, object: nil)
                dismiss()
            }
        }
    }
}
