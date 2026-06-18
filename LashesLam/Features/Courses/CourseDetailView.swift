//
//  CourseDetailView.swift
//  LashesLam
//
//  Detalle del curso replicando el de Android: imagen, costos (total/apartado/
//  horario), ubicación (abre mapas), descripción, temario, instructora, redes
//  sociales y botón de estado de inscripción.
//

import SwiftUI

struct CourseDetailView: View {
    let courseId: String
    @StateObject private var viewModel: CourseDetailViewModel
    @EnvironmentObject var session: SessionManager

    init(courseId: String) {
        self.courseId = courseId
        _viewModel = StateObject(wrappedValue: CourseDetailViewModel(courseId: courseId))
    }

    var body: some View {
        ScrollView {
            if let course = viewModel.course {
                VStack(alignment: .leading, spacing: 16) {
                    courseImage(course.imagen)

                    VStack(alignment: .leading, spacing: 16) {
                        Text(course.titulo)
                            .font(.appTitle(26)).foregroundColor(AppColors.onSurface)

                        costRow(course)
                        locationCard(course)

                        if !course.descripcion.isEmpty {
                            section("Sobre el curso") {
                                Text(course.descripcion).font(.body).foregroundColor(AppColors.onSurfaceVariant)
                            }
                        }

                        if !course.temarios.isEmpty {
                            section("Temario") {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(course.temarios, id: \.self) { item in
                                        Label(item, systemImage: "checkmark.circle.fill")
                                            .font(.subheadline).foregroundColor(AppColors.onSurfaceVariant)
                                    }
                                }
                            }
                        }

                        if !course.instructora.isEmpty {
                            instructorCard(course)
                        }

                        Text("Solicita información")
                            .font(.body).foregroundColor(AppColors.onSurfaceVariant)
                            .padding(.top, 8)
                        SocialMediaRow(
                            whatsAppURL: whatsAppURL(course),
                            instagram: session.instagram,
                            facebook: session.facebook
                        )

                        enrollmentSection
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 32)
            } else if viewModel.isLoading {
                ProgressView().tint(AppColors.pinkPrimary).padding(.top, 80)
            }
        }
        .background(AppColors.surface.ignoresSafeArea())
        .navigationTitle("Curso")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteHeartButton(itemId: courseId, type: .course, bare: true)
            }
        }
        .onAppear { viewModel.load() }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } })
        ) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "") }
    }

    // MARK: - Imagen (4:3, fit, fondo surfaceVariant como Android)

    private func courseImage(_ url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image): image.resizable().scaledToFit()
            case .empty: ProgressView()
            case .failure: Image(systemName: "graduationcap").font(.largeTitle).foregroundColor(.gray)
            @unknown default: Color.clear
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(4.0/3.0, contentMode: .fit)
        .background(AppColors.surfaceVariant)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    // MARK: - Fila de costos

    private func costRow(_ course: CourseDetail) -> some View {
        HStack(alignment: .top, spacing: 8) {
            costItem(icon: "creditcard", label: "Costo total", value: Formatters.money(course.priceValue))
            if !course.apartar.isEmpty {
                costItem(icon: "wallet.pass", label: "Apartado", value: Formatters.money(Double(course.apartar) ?? 0))
            }
            costItem(icon: "timer", label: "Horario",
                     value: duration(course.horaInicio, course.horaFin),
                     subValue: "\(course.horaInicio) - \(course.horaFin)")
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private func costItem(icon: String, label: String, value: String, subValue: String? = nil) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).foregroundColor(AppColors.pinkPrimary)
            Text(label).font(.caption2).foregroundColor(.gray)
            Text(value).font(.subheadline.bold()).foregroundColor(AppColors.onSurface)
            if let subValue { Text(subValue).font(.caption2).foregroundColor(.gray) }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Ubicación (abre mapas)

    private func locationCard(_ course: CourseDetail) -> some View {
        Button {
            if MapsHelper.hasLocation(lat: course.lat, lng: course.lng) {
                MapsHelper.openLocation(lat: course.lat!, lng: course.lng!, name: course.ubicacionNombre)
            }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "calendar")
                    .foregroundColor(AppColors.pinkPrimary)
                    .frame(width: 56, height: 56)
                    .background(Color(red: 0.99, green: 0.95, blue: 0.94))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                VStack(alignment: .leading, spacing: 2) {
                    Text(course.fecha).font(.headline).foregroundColor(AppColors.onSurface)
                    Text("\(course.ubicacionNombre ?? "Ubicación") · Ver ubicación")
                        .font(.subheadline).foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.gray.opacity(0.5))
            }
            .padding(16)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .disabled(!MapsHelper.hasLocation(lat: course.lat, lng: course.lng))
    }

    // MARK: - Instructora

    private func instructorCard(_ course: CourseDetail) -> some View {
        section("Instructora") {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: course.instructoraImage)) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    case .empty: ProgressView()
                    default: Image(systemName: "person.fill").foregroundColor(.gray)
                    }
                }
                .frame(width: 80, height: 80)
                .background(AppColors.surfaceVariant)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(course.instructora).font(.headline)
                    if !course.instructoraDesc.isEmpty {
                        Text(course.instructoraDesc).font(.subheadline).foregroundColor(AppColors.onSurfaceVariant)
                    }
                }
            }
        }
    }

    // MARK: - Estado de inscripción

    @ViewBuilder
    private var enrollmentSection: some View {
        if let label = viewModel.statusLabel, !viewModel.canRequest {
            HStack {
                Image(systemName: viewModel.status == CoursesRepository.CourseStatus.accepted ? "checkmark.seal.fill" : "hourglass")
                Text(label).fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity).padding()
            .background(AppColors.pinkTertiary.opacity(0.4))
            .foregroundColor(AppColors.onSurface)
            .clipShape(Capsule())
            .padding(.top, 8)
        } else {
            Button { viewModel.requestEnrollment() } label: {
                HStack {
                    if viewModel.isRequesting { ProgressView().tint(.white) }
                    else { Image(systemName: "graduationcap.fill"); Text("Solicitar inscripción").fontWeight(.bold) }
                }
                .frame(maxWidth: .infinity).padding()
                .background(AppColors.pinkPrimary).foregroundColor(.white)
                .clipShape(Capsule())
            }
            .disabled(viewModel.isRequesting)
            .padding(.top, 8)
        }
    }

    // MARK: - Helpers

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.appTitleMedium(22)).fontWeight(.bold).foregroundColor(AppColors.onSurface)
            content()
        }
        .padding(.top, 4)
    }

    private func whatsAppURL(_ course: CourseDetail) -> URL? {
        let whatsapp = (session.whatsApp?.isEmpty == false) ? session.whatsApp! : "5514023853"
        return Formatters.whatsAppProductURL(
            title: course.titulo,
            price: Formatters.money(course.priceValue),
            whatsapp: whatsapp
        )
    }

    private func duration(_ start: String, _ end: String) -> String {
        let s = start.split(separator: ":"), e = end.split(separator: ":")
        guard s.count >= 2, e.count >= 2,
              let sh = Int(s[0].trimmingCharacters(in: .whitespaces)),
              let sm = Int(s[1].prefix(2)),
              let eh = Int(e[0].trimmingCharacters(in: .whitespaces)),
              let em = Int(e[1].prefix(2)) else { return "N/A" }
        let startMin = sh * 60 + sm, endMin = eh * 60 + em
        let diff = endMin >= startMin ? endMin - startMin : (24 * 60 - startMin) + endMin
        let h = diff / 60, m = diff % 60
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0 { return "\(h)h" }
        return "\(m)m"
    }
}
