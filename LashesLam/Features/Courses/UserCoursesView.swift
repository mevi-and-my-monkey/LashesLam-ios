//
//  UserCoursesView.swift
//  LashesLam
//
//  Inscripciones del usuario (sus solicitudes a cursos y su estado).
//

import SwiftUI

@MainActor
final class UserCoursesViewModel: ObservableObject {
    @Published var items: [CourseRequest] = []
    @Published var isLoading = false

    private let repository = CoursesRepository()
    private let session = SessionManager.shared

    func load() {
        Task {
            isLoading = true
            let result = await repository.getUserCourseRequests(userId: session.currentUserId ?? "")
            isLoading = false
            if case .success(let list) = result { items = list }
        }
    }
}

struct UserCoursesView: View {
    @StateObject private var viewModel = UserCoursesViewModel()

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            if viewModel.items.isEmpty && !viewModel.isLoading {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.items) { item in card(item) }
                    }
                    .padding(16)
                }
            }
            if viewModel.isLoading { LottieView(name: "loading").frame(width: 100, height: 100) }
        }
        .onAppear { viewModel.load() }
        .refreshable { viewModel.load() }
    }

    private func card(_ item: CourseRequest) -> some View {
        let style = courseStatusStyle(item.status)
        return HStack(spacing: 0) {
            Rectangle().fill(style.color).frame(width: 5)
            VStack(alignment: .leading, spacing: 8) {
                // Título + costo/apartado
                HStack(alignment: .top) {
                    Text(item.courseName.uppercased())
                        .font(.appTitleMedium(18)).fontWeight(.bold)
                        .foregroundColor(AppColors.pinkPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(priceText(item.price))
                            .font(.appTitleMedium(22)).fontWeight(.bold)
                            .foregroundColor(AppColors.onSurface)
                        if !item.apartar.isEmpty {
                            Text("Apartar \(item.apartar)")
                                .font(.caption2).foregroundColor(.gray)
                        }
                    }
                }

                // Fecha + horario
                HStack(spacing: 8) {
                    Image(systemName: "calendar").font(.system(size: 13)).foregroundColor(.gray)
                    Text(item.schedule.isEmpty ? item.date : "\(item.date) · \(item.schedule)")
                        .font(.caption).foregroundColor(.darkGrayCompat)
                }

                // Ubicación
                if !item.location.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.and.ellipse").font(.system(size: 13)).foregroundColor(.gray)
                        Text(item.location).font(.caption).foregroundColor(.gray)
                    }
                }

                Divider().padding(.vertical, 4)

                // Estado + ver detalle
                HStack {
                    HStack(spacing: 8) {
                        Circle().fill(style.color).frame(width: 6, height: 6)
                        Text(style.label).font(.caption.bold()).foregroundColor(style.color)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(style.background).clipShape(Capsule())

                    Spacer()

                    NavigationLink { CourseDetailView(courseId: item.courseId) } label: {
                        HStack(spacing: 2) {
                            Text("Ver detalle").font(.caption.bold())
                            Image(systemName: "chevron.right").font(.system(size: 12))
                        }
                        .foregroundColor(AppColors.pinkPrimary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }

    private func priceText(_ price: String) -> String {
        if let value = Double(price) { return Formatters.money(value) }
        return price
    }

    private func courseStatusStyle(_ status: String) -> (color: Color, background: Color, label: String) {
        switch status {
        case CoursesRepository.CourseStatus.accepted:
            return (Color(red: 0.30, green: 0.44, blue: 0.27), Color(red: 0.91, green: 0.94, blue: 0.90), "Aceptado")
        case CoursesRepository.CourseStatus.rejected:
            return (Color(red: 0.80, green: 0.25, blue: 0.25), Color(red: 0.98, green: 0.91, blue: 0.91), "Rechazado")
        default:
            return (Color(red: 0.55, green: 0.45, blue: 0.33), Color(red: 0.98, green: 0.95, blue: 0.91), "Pendiente")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "graduationcap").font(.system(size: 56)).foregroundColor(.gray.opacity(0.4))
            Text("Aún no tienes inscripciones").font(.subheadline).foregroundColor(.gray)
        }
        .padding(32)
    }
}
