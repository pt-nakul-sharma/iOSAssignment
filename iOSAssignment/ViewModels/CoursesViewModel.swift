//
//  CoursesViewModel.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import Foundation

enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)
}

@Observable
final class CoursesViewModel {

    var state: ViewState<[Course]> = .idle

    private let apiService: APIService
    private let authManager: AuthManager

    init(apiService: APIService = .shared, authManager: AuthManager = .shared) {
        self.apiService = apiService
        self.authManager = authManager
    }

    func loadCourses(forceRefresh: Bool = false) async {
        state = .loading
        do {
            let courses = try await apiService.getEnrolledCourses(
                token: authManager.token,
                userId: authManager.userId,
                forceRefresh: forceRefresh
            )
            let sortedCourses = courses.sorted { $0.progressPercentage > $1.progressPercentage }
            state = .loaded(sortedCourses)
        } catch let error as APIError {
            state = .error(error.errorDescription ?? "Failed to load courses.")
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
