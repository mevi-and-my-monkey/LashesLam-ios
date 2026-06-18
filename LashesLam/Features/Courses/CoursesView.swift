//
//  CoursesView.swift
//  LashesLam
//
//  Lista de cursos con navegación al detalle. Se accede desde Inicio.
//

import SwiftUI

struct CoursesView: View {
    @StateObject private var viewModel = CoursesViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.courses) { course in
                    ZStack(alignment: .topTrailing) {
                        NavigationLink {
                            CourseDetailView(courseId: course.id)
                        } label: {
                            CourseCard(course: course)
                        }
                        .buttonStyle(.plain)
                        FavoriteHeartButton(itemId: course.id, type: .course).padding(14)
                    }
                }
            }
            .padding(16)
        }
        .background(AppColors.background.ignoresSafeArea())
        .overlay {
            if viewModel.isLoading {
                ProgressView().tint(AppColors.pinkPrimary)
            } else if viewModel.courses.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "graduationcap").font(.system(size: 44)).foregroundColor(.gray.opacity(0.5))
                    Text("Sin cursos").font(.headline)
                    Text("Aún no hay cursos disponibles.").font(.subheadline).foregroundColor(.gray)
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } })
        ) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "") }
        .onAppear { if viewModel.courses.isEmpty { viewModel.load() } }
        .refreshable { viewModel.load() }
    }
}
