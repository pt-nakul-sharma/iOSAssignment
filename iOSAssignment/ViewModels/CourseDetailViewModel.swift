//
//  CourseDetailViewModel.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import Foundation

@Observable
final class CourseDetailViewModel {

    var state: ViewState<[CourseSection]> = .idle

    private let apiService: APIService
    private let authManager: AuthManager
    let course: Course

    init(course: Course, apiService: APIService = .shared, authManager: AuthManager = .shared) {
        self.course = course
        self.apiService = apiService
        self.authManager = authManager
    }

    func loadContents() async {
        state = .loading
        do {
            let sections = try await apiService.getCourseContents(
                token: authManager.token,
                courseId: course.id
            )
            state = .loaded(sections)
        } catch let error as APIError {
            state = .error(error.errorDescription ?? "Failed to load course contents.")
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
