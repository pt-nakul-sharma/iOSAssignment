//
//  CoursesView.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import SwiftUI

struct CoursesView: View {
    @State private var viewModel = CoursesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    LoadingView(message: "Loading courses...")

                case .loaded(let courses):
                    if courses.isEmpty {
                        ContentUnavailableView(
                            "No Courses",
                            systemImage: "book.closed",
                            description: Text("You are not enrolled in any courses.")
                        )
                    } else {
                        coursesList(courses)
                    }

                case .error(let message):
                    ErrorView(message: message) {
                        Task { await viewModel.loadCourses() }
                    }
                }
            }
            .navigationTitle("My Courses")
            .task {
                if case .idle = viewModel.state {
                    await viewModel.loadCourses()
                }
            }
            .refreshable {
                await viewModel.loadCourses(forceRefresh: true)
            }
        }
    }

    @ViewBuilder
    private func coursesList(_ courses: [Course]) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(courses) { course in
                    NavigationLink(value: course) {
                        CourseCardView(course: course)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .navigationDestination(for: Course.self) { course in
            CourseDetailView(course: course)
        }
    }
}

#Preview {
    CoursesView()
}
