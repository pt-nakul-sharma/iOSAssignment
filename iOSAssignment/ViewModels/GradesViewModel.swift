//
//  GradesViewModel.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import Foundation

@Observable
final class GradesViewModel {

    var state: ViewState<[UserGrade]> = .idle

    private let apiService: APIService
    private let authManager: AuthManager

    init(apiService: APIService = .shared, authManager: AuthManager = .shared) {
        self.apiService = apiService
        self.authManager = authManager
    }

    private var loadTask: Task<Void, Never>?

    @MainActor
    func loadGrades() async {
        loadTask?.cancel()

        state = .loading

        let task = Task.detached { [apiService, authManager] () -> [UserGrade] in
            do {
                let courses = try await apiService.getEnrolledCourses(
                    token: authManager.token,
                    userId: authManager.userId
                )

                let courseNameMap = Dictionary(uniqueKeysWithValues: courses.map { ($0.id, $0.fullname) })

                var allGrades: [UserGrade] = []
                for course in courses {
                    do {
                        let response = try await apiService.getGradeItems(
                            token: authManager.token,
                            userId: authManager.userId,
                            courseId: course.id
                        )
                        let grades = (response.usergrades ?? []).map { grade in
                            var g = grade
                            g.injectedCourseName = courseNameMap[grade.courseid ?? 0]
                            return g
                        }
                        // Filter out courses with no meaningful grades
                        let meaningful = grades.filter { Self.hasMeaningfulGrades($0) }
                        allGrades.append(contentsOf: meaningful)
                    } catch {
                        AppLogger.error("Failed to load grades for course \(course.id): \(error)")
                    }
                }
                return allGrades
            } catch {
                throw error
            }
        }

        loadTask = Task {
            do {
                let grades = try await task.value
                state = .loaded(grades)
            } catch let error as APIError {
                state = .error(error.errorDescription ?? "Failed to load grades.")
            } catch {
                state = .error(error.localizedDescription)
            }
        }

        await loadTask?.value
    }

    // MARK: - Helpers

    static func hasMeaningfulGrades(_ userGrade: UserGrade) -> Bool {
        guard let items = userGrade.gradeitems, !items.isEmpty else { return false }
        // Has actual assignment/module grade items (not just course total)
        let hasModItems = items.contains { $0.itemtype == "mod" }
        // Or has a course total with an actual grade
        let hasGradedTotal = items.contains { $0.isCourseTotal && $0.graderaw != nil }
        return hasModItems || hasGradedTotal
    }
}
