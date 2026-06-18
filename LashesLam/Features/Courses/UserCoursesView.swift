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
            if viewModel.isLoading { ProgressView().tint(AppColors.pinkPrimary) }
        }
        .onAppear { viewModel.load() }
        .refreshable { viewModel.load() }
    }

    private func card(_ item: CourseRequest) -> some View {
        let style = courseStatusStyle(item.status)
        return HStack(spacing: 0) {
            Rectangle().fill(style.color).frame(width: 5)
            VStack(alignment: .leading, spacing: 6) {
                Text(item.courseName).font(.appTitleMedium(18)).fontWeight(.bold)
                    .foregroundColor(AppColors.onSurface)
                HStack(spacing: 12) {
                    Label(item.date, systemImage: "calendar")
                    if !item.schedule.isEmpty { Label(item.schedule, systemImage: "clock") }
                }
                .font(.caption).foregroundColor(.gray)
                HStack(spacing: 8) {
                    Circle().fill(style.color).frame(width: 6, height: 6)
                    Text(style.label).font(.caption.bold()).foregroundColor(style.color)
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(style.background).clipShape(Capsule())
            }
            .padding(16)
            Spacer()
        }
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
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
