//
//  CourseDetailView.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import SwiftUI

struct CourseDetailView: View {
    @State private var viewModel: CourseDetailViewModel

    init(course: Course) {
        _viewModel = State(initialValue: CourseDetailViewModel(course: course))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                LoadingView(message: "Loading course contents...")

            case .loaded(let sections):
                let visibleSections = sections.filter { section in
                    guard let modules = section.modules else { return false }
                    return !modules.isEmpty
                }
                if visibleSections.isEmpty {
                    ContentUnavailableView(
                        "No Content",
                        systemImage: "doc.text",
                        description: Text("This course has no content yet.")
                    )
                } else {
                    sectionsList(visibleSections)
                }

            case .error(let message):
                ErrorView(message: message) {
                    Task { await viewModel.loadContents() }
                }
            }
        }
        .navigationTitle(viewModel.course.fullname)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if case .idle = viewModel.state {
                await viewModel.loadContents()
            }
        }
    }

    @ViewBuilder
    private func sectionsList(_ sections: [CourseSection]) -> some View {
        List {
            ForEach(sections) { section in
                Section {
                    if let modules = section.modules {
                        ForEach(modules) { module in
                            HStack(spacing: 12) {
                                Image(systemName: moduleIcon(for: module.modname))
                                    .font(.body)
                                    .foregroundStyle(.tint)
                                    .frame(width: 28)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(module.name)
                                        .font(.subheadline)

                                    if let modname = module.modname {
                                        Text(modname.capitalized)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text(section.name.isEmpty ? "General" : section.name)
                        .font(.headline)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func moduleIcon(for modname: String?) -> String {
        switch modname {
        case "assign": return "doc.text.fill"
        case "quiz": return "questionmark.circle.fill"
        case "forum": return "bubble.left.and.bubble.right.fill"
        case "resource": return "doc.fill"
        case "url": return "link"
        case "page": return "doc.richtext.fill"
        case "folder": return "folder.fill"
        case "label": return "tag.fill"
        case "book": return "book.fill"
        case "chat": return "message.fill"
        case "choice": return "checklist"
        case "feedback": return "star.fill"
        case "lesson": return "list.bullet.rectangle.fill"
        case "workshop": return "person.3.fill"
        case "glossary": return "character.book.closed.fill"
        case "wiki": return "globe"
        default: return "circle.fill"
        }
    }
}
