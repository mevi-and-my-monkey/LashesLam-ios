//
//  CourseRequestsView.swift
//  LashesLam
//
//  Admin: solicitudes de inscripción pendientes, con aprobar/rechazar.
//

import SwiftUI

struct CourseRequestsView: View {
    @StateObject private var viewModel = CourseRequestsViewModel()

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if viewModel.requests.isEmpty && !viewModel.isLoading {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.requests) { request in
                            requestCard(request)
                        }
                    }
                    .padding(16)
                }
            }

            if viewModel.isLoading { LottieView(name: "loading").frame(width: 100, height: 100) }
        }
        .onAppear { viewModel.load() }
        .refreshable { viewModel.load() }
        .errorDialog($viewModel.errorMessage)
    }

    private func requestCard(_ request: CourseRequest) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(request.courseName)
                .font(.appTitleMedium(18)).fontWeight(.bold)
                .foregroundColor(AppColors.onSurface)

            Label(request.nameUser, systemImage: "person.fill").font(.subheadline).foregroundColor(.gray)
            if !request.emailUser.isEmpty {
                Label(request.emailUser, systemImage: "envelope").font(.caption).foregroundColor(.gray)
            }
            HStack(spacing: 12) {
                Label(request.date, systemImage: "calendar")
                Label(request.schedule, systemImage: "clock")
            }
            .font(.caption).foregroundColor(.gray)
            if !request.price.isEmpty {
                Text(Formatters.money(Double(request.price) ?? 0))
                    .font(.subheadline.bold()).foregroundColor(AppColors.pinkPrimary)
            }

            Divider()

            HStack(spacing: 10) {
                Button { viewModel.approve(request.requestId) } label: {
                    Text("Aprobar").font(.subheadline.bold())
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .background(Color(red: 0.30, green: 0.44, blue: 0.27))
                        .foregroundColor(.white).clipShape(Capsule())
                }
                Button { viewModel.reject(request.requestId) } label: {
                    Text("Rechazar").font(.subheadline.bold())
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .background(Color(red: 0.80, green: 0.25, blue: 0.25))
                        .foregroundColor(.white).clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "graduationcap")
                .font(.system(size: 56)).foregroundColor(.gray.opacity(0.4))
            Text("Sin solicitudes pendientes").font(.subheadline).foregroundColor(.gray)
        }
        .padding(32)
    }
}
