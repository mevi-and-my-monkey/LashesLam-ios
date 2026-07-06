//
//  CoursesView.swift
//  LashesLam
//
//  Sección de cursos del Home (igual que CursosPageContent.kt de Android): banner,
//  título "Cursos disponibles" + "Ver todos", y solo los cursos de fechas futuras.
//  El listado completo (sin filtro de fecha) vive en la búsqueda / "Ver todos".
//

import SwiftUI

struct CoursesView: View {
    var onSearch: () -> Void = {}

    @StateObject private var viewModel = CoursesViewModel()
    @State private var bannerCourseId: String?
    @State private var showBannerCourse = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                HomeBannerView { id in
                    bannerCourseId = id
                    showBannerCourse = true
                }

                HStack {
                    Text("Cursos disponibles")
                        .font(.appTitleMedium(24)).fontWeight(.bold)
                        .foregroundColor(AppColors.onBackground)
                    Spacer()
                    Button("Ver todos", action: onSearch)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.pinkPrimary)
                }
                .padding(.horizontal, 16)

                ForEach(viewModel.futureCourses) { course in
                    ZStack(alignment: .topTrailing) {
                        NavigationLink {
                            CourseDetailView(courseId: course.id)
                        } label: {
                            CourseCard(course: course)
                        }
                        .buttonStyle(.plain)
                        FavoriteHeartButton(itemId: course.id, type: .course).padding(14)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 8)
        }
        .background(AppColors.background.ignoresSafeArea())
        .overlay {
            if viewModel.isLoading {
                LottieView(name: "loading").frame(width: 100, height: 100)
            } else if viewModel.futureCourses.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "graduationcap").font(.system(size: 44)).foregroundColor(.gray.opacity(0.5))
                    Text("Sin cursos").font(.headline)
                    Text("Aún no hay cursos disponibles.").font(.subheadline).foregroundColor(.gray)
                }
            }
        }
        .navigationDestination(isPresented: $showBannerCourse) {
            if let id = bannerCourseId { CourseDetailView(courseId: id) }
        }
        .errorDialog($viewModel.errorMessage)
        .onAppear { if viewModel.courses.isEmpty { viewModel.load() } }
        .refreshable { viewModel.load() }
    }
}
