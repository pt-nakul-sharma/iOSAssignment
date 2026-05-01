//
//  GradesView.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import SwiftUI

struct GradesView: View {
    @State private var viewModel = GradesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    LoadingView(message: "Loading grades...")

                case .loaded(let userGrades):
                    if userGrades.isEmpty {
                        ContentUnavailableView(
                            "No Grades",
                            systemImage: "chart.bar",
                            description: Text("No grade data available.")
                        )
                    } else {
                        gradesList(sortedGrades(userGrades))
                    }

                case .error(let message):
                    ErrorView(message: message) {
                        Task { await viewModel.loadGrades() }
                    }
                }
            }
            .navigationTitle("Grades")
            .task {
                if case .idle = viewModel.state {
                    await viewModel.loadGrades()
                }
            }
            .refreshable {
                await viewModel.loadGrades()
            }
        }
    }

    private func sortedGrades(_ userGrades: [UserGrade]) -> [UserGrade] {
        userGrades.sorted {
            $0.displayCourseName.localizedCaseInsensitiveCompare($1.displayCourseName) == .orderedAscending
        }
    }

    private func sortedItems(_ items: [GradeItem]) -> [GradeItem] {
        items.sorted { a, b in
            if a.isCourseTotal != b.isCourseTotal { return !a.isCourseTotal }
            return a.displayName.localizedCaseInsensitiveCompare(b.displayName) == .orderedAscending
        }
    }

    @ViewBuilder
    private func gradesList(_ userGrades: [UserGrade]) -> some View {
        List {
            ForEach(userGrades, id: \.courseid) { userGrade in
                Section {
                    if let items = userGrade.gradeitems, !items.isEmpty {
                        ForEach(sortedItems(items)) { item in
                            gradeRow(item)
                        }
                    } else {
                        Text("No grade items")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(userGrade.displayCourseName)
                        .font(.headline)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private func gradeRow(_ item: GradeItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayName)
                    .font(item.isCourseTotal ? .subheadline.bold() : .subheadline)

                if let itemmodule = item.itemmodule, !item.isCourseTotal {
                    Text(itemmodule.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if item.isCourseTotal {
                    Text("Overall")
                        .font(.caption)
                        .foregroundStyle(.teal)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.displayGrade)
                    .font(item.isCourseTotal ? .subheadline.bold() : .subheadline)
                    .foregroundStyle(item.isCourseTotal ? .teal : .primary)

                Text(item.displayPercentage)
                    .font(.caption)
                    .foregroundStyle(item.isCourseTotal ? .teal : .secondary)
            }
        }
        .padding(.vertical, 4)
        .listRowBackground(item.isCourseTotal ? Color.teal.opacity(0.08) : nil)
    }
}

#Preview {
    GradesView()
}
