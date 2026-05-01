//
//  iOSAssignmentTests.swift
//  iOSAssignmentTests
//
//  Created by Nakul Sharma on 01/05/26.
//

import Testing
import Foundation
@testable import iOSAssignment

// MARK: - Model Tests

struct AuthTokenResponseTests {
    @Test func tokenResponseProperties() async throws {
        let response = AuthTokenResponse(
            token: "test_token_123",
            privatetoken: "private_token_456",
            error: nil,
            errorcode: nil
        )

        #expect(response.token == "test_token_123")
        #expect(response.privatetoken == "private_token_456")
        #expect(response.error == nil)
        #expect(response.errorcode == nil)
    }

    @Test func errorResponseProperties() async throws {
        let response = AuthTokenResponse(
            token: nil,
            privatetoken: nil,
            error: "Invalid credentials",
            errorcode: "invalidlogin"
        )

        #expect(response.token == nil)
        #expect(response.error == "Invalid credentials")
        #expect(response.errorcode == "invalidlogin")
    }
}

struct CourseTests {
    @Test func courseProperties() async throws {
        let course = Course(
            id: 123,
            fullname: "Introduction to Swift",
            shortname: "SWIFT101",
            progress: 75.5,
            courseimage: "https://example.com/image.jpg",
            overviewfiles: nil
        )

        #expect(course.id == 123)
        #expect(course.fullname == "Introduction to Swift")
        #expect(course.shortname == "SWIFT101")
        #expect(course.progress == 75.5)
        #expect(course.courseimage == "https://example.com/image.jpg")
    }

    @Test func displayImageUsesCourseImage() async throws {
        let course = Course(
            id: 1,
            fullname: "Test Course",
            shortname: "TEST",
            progress: 50.0,
            courseimage: "https://example.com/image.jpg",
            overviewfiles: nil
        )

        #expect(course.displayImage == "https://example.com/image.jpg")
    }

    @Test func displayImageUsesOverviewFileWhenCourseImageEmpty() async throws {
        let overviewFile = OverviewFile(
            fileurl: "https://example.com/overview.jpg",
            filename: "overview.jpg",
            mimetype: "image/jpeg"
        )
        let course = Course(
            id: 1,
            fullname: "Test Course",
            shortname: "TEST",
            progress: 50.0,
            courseimage: "",
            overviewfiles: [overviewFile]
        )

        #expect(course.displayImage == "https://example.com/overview.jpg")
    }

    @Test func displayImageReturnsNilWhenNoImageAvailable() async throws {
        let course = Course(
            id: 1,
            fullname: "Test Course",
            shortname: "TEST",
            progress: 50.0,
            courseimage: nil,
            overviewfiles: nil
        )

        #expect(course.displayImage == nil)
    }

    @Test func progressPercentageReturnsProgress() async throws {
        let course = Course(
            id: 1,
            fullname: "Test Course",
            shortname: "TEST",
            progress: 75.5,
            courseimage: nil,
            overviewfiles: nil
        )

        #expect(course.progressPercentage == 75.5)
    }

    @Test func progressPercentageReturnsZeroWhenProgressNil() async throws {
        let course = Course(
            id: 1,
            fullname: "Test Course",
            shortname: "TEST",
            progress: nil,
            courseimage: nil,
            overviewfiles: nil
        )

        #expect(course.progressPercentage == 0.0)
    }

    @Test func courseEquality() async throws {
        let course1 = Course(
            id: 1,
            fullname: "Course 1",
            shortname: "C1",
            progress: 50.0,
            courseimage: nil,
            overviewfiles: nil
        )
        let course2 = Course(
            id: 1,
            fullname: "Different Name",
            shortname: "D1",
            progress: 75.0,
            courseimage: nil,
            overviewfiles: nil
        )
        let course3 = Course(
            id: 2,
            fullname: "Course 1",
            shortname: "C1",
            progress: 50.0,
            courseimage: nil,
            overviewfiles: nil
        )

        #expect(course1 == course2)
        #expect(course1 != course3)
    }
}

struct CourseSectionTests {
    @Test func courseSectionProperties() async throws {
        let section = CourseSection(
            id: 1,
            name: "Week 1",
            summary: "Introduction to the course",
            modules: [
                CourseModule(
                    id: 10,
                    name: "Assignment 1",
                    modname: "assign",
                    modplural: "Assignments",
                    description: "First assignment"
                )
            ]
        )

        #expect(section.id == 1)
        #expect(section.name == "Week 1")
        #expect(section.summary == "Introduction to the course")
        #expect(section.modules?.count == 1)
        #expect(section.modules?.first?.name == "Assignment 1")
    }

    @Test func courseModuleWithOptionalFields() async throws {
        let module = CourseModule(
            id: 10,
            name: "Resource",
            modname: "resource",
            modplural: "Resources",
            description: nil
        )

        #expect(module.id == 10)
        #expect(module.name == "Resource")
        #expect(module.modname == "resource")
        #expect(module.description == nil)
    }
}

struct GradeItemTests {
    @Test func gradeResponseProperties() async throws {
        let response = GradeResponse(
            usergrades: [
                UserGrade(
                    courseid: 123,
                    courseidnumber: "C123",
                    userid: 456,
                    userfullname: "John Doe",
                    gradeitems: [
                        GradeItem(
                            id: 1,
                            itemname: "Assignment 1",
                            itemtype: "mod",
                            itemmodule: nil,
                            graderaw: 85.0,
                            gradeformatted: "85.0",
                            grademin: 0.0,
                            grademax: 100.0,
                            percentageformatted: "85%",
                            feedback: nil
                        )
                    ]
                )
            ],
            warnings: nil
        )

        #expect(response.usergrades?.count == 1)
        #expect(response.usergrades?.first?.courseid == 123)
        #expect(response.usergrades?.first?.gradeitems?.count == 1)
    }

    @Test func gradeItemIsCourseTotal() async throws {
        let courseTotalItem = GradeItem(
            id: 1,
            itemname: "Course Total",
            itemtype: "course",
            itemmodule: nil,
            graderaw: 85.0,
            gradeformatted: "85.0",
            grademin: 0.0,
            grademax: 100.0,
            percentageformatted: "85%",
            feedback: nil
        )

        let moduleItem = GradeItem(
            id: 2,
            itemname: "Assignment 1",
            itemtype: "mod",
            itemmodule: "assign",
            graderaw: 90.0,
            gradeformatted: "90.0",
            grademin: 0.0,
            grademax: 100.0,
            percentageformatted: "90%",
            feedback: nil
        )

        #expect(courseTotalItem.isCourseTotal == true)
        #expect(moduleItem.isCourseTotal == false)
    }

    @Test func gradeItemDisplayName() async throws {
        let namedItem = GradeItem(
            id: 1,
            itemname: "Assignment 1",
            itemtype: "mod",
            itemmodule: nil,
            graderaw: 85.0,
            gradeformatted: "85.0",
            grademin: 0.0,
            grademax: 100.0,
            percentageformatted: "85%",
            feedback: nil
        )

        let unnamedCourseItem = GradeItem(
            id: 2,
            itemname: "",
            itemtype: "course",
            itemmodule: nil,
            graderaw: 85.0,
            gradeformatted: "85.0",
            grademin: 0.0,
            grademax: 100.0,
            percentageformatted: "85%",
            feedback: nil
        )

        let unnamedModuleItem = GradeItem(
            id: 3,
            itemname: "",
            itemtype: "mod",
            itemmodule: nil,
            graderaw: 85.0,
            gradeformatted: "85.0",
            grademin: 0.0,
            grademax: 100.0,
            percentageformatted: "85%",
            feedback: nil
        )

        #expect(namedItem.displayName == "Assignment 1")
        #expect(unnamedCourseItem.displayName == "Course Total")
        #expect(unnamedModuleItem.displayName == "Unnamed Item")
    }

    @Test func gradeItemDisplayGrade() async throws {
        let formattedItem = GradeItem(
            id: 1,
            itemname: "Assignment 1",
            itemtype: "mod",
            itemmodule: nil,
            graderaw: 85.0,
            gradeformatted: "85.5/100",
            grademin: 0.0,
            grademax: 100.0,
            percentageformatted: "85.5%",
            feedback: nil
        )

        let dashItem = GradeItem(
            id: 2,
            itemname: "Assignment 2",
            itemtype: "mod",
            itemmodule: nil,
            graderaw: 85.0,
            gradeformatted: "-",
            grademin: 0.0,
            grademax: 100.0,
            percentageformatted: nil,
            feedback: nil
        )

        let rawItem = GradeItem(
            id: 3,
            itemname: "Assignment 3",
            itemtype: "mod",
            itemmodule: nil,
            graderaw: 90.5,
            gradeformatted: nil,
            grademin: 0.0,
            grademax: 100.0,
            percentageformatted: nil,
            feedback: nil
        )

        let noGradeItem = GradeItem(
            id: 4,
            itemname: "Assignment 4",
            itemtype: "mod",
            itemmodule: nil,
            graderaw: nil,
            gradeformatted: nil,
            grademin: 0.0,
            grademax: 100.0,
            percentageformatted: nil,
            feedback: nil
        )

        #expect(formattedItem.displayGrade == "85.5/100")
        #expect(dashItem.displayGrade == "85.0")
        #expect(rawItem.displayGrade == "90.5")
        #expect(noGradeItem.displayGrade == "—")
    }

    @Test func userGradeDisplayCourseName() async throws {
        var userGrade = UserGrade(
            courseid: 123,
            courseidnumber: "C123",
            userid: 456,
            userfullname: "John Doe",
            gradeitems: nil
        )

        #expect(userGrade.displayCourseName == "Course 123")

        userGrade.injectedCourseName = "Introduction to Swift"
        #expect(userGrade.displayCourseName == "Introduction to Swift")
    }

    @Test func userGradeCourseTotalGrade() async throws {
        let courseTotal = GradeItem(
            id: 1,
            itemname: "Course Total",
            itemtype: "course",
            itemmodule: nil,
            graderaw: 85.5,
            gradeformatted: "85.5",
            grademin: 0.0,
            grademax: 100.0,
            percentageformatted: "85.5%",
            feedback: nil
        )

        let assignment = GradeItem(
            id: 2,
            itemname: "Assignment 1",
            itemtype: "mod",
            itemmodule: "assign",
            graderaw: 90.0,
            gradeformatted: "90.0",
            grademin: 0.0,
            grademax: 100.0,
            percentageformatted: "90%",
            feedback: nil
        )

        var userGradeWithTotal = UserGrade(
            courseid: 123,
            courseidnumber: "C123",
            userid: 456,
            userfullname: "John Doe",
            gradeitems: [assignment, courseTotal]
        )

        var userGradeWithoutTotal = UserGrade(
            courseid: 124,
            courseidnumber: "C124",
            userid: 456,
            userfullname: "John Doe",
            gradeitems: [assignment]
        )

        #expect(userGradeWithTotal.courseTotalGrade == 85.5)
        #expect(userGradeWithoutTotal.courseTotalGrade == nil)
    }
}

// MARK: - APIError Tests

struct APIErrorTests {
    @Test func errorDescriptions() async throws {
        let invalidURLError = APIError.invalidURL
        #expect(invalidURLError.errorDescription == "Invalid URL.")

        let networkError = APIError.networkError(NSError(domain: "test", code: -1))
        #expect(networkError.errorDescription?.contains("Network error") == true)

        let decodingError = APIError.decodingError(NSError(domain: "test", code: -1))
        #expect(decodingError.errorDescription?.contains("Failed to parse response") == true)

        let serverError = APIError.serverError("Server maintenance")
        #expect(serverError.errorDescription == "Server maintenance")

        let unauthorizedError = APIError.unauthorized
        #expect(unauthorizedError.errorDescription == "Authentication failed. Please check your credentials.")

        let unknownError = APIError.unknown
        #expect(unknownError.errorDescription == "An unknown error occurred.")
    }
}

// MARK: - ViewState Tests

struct ViewStateTests {
    @Test func viewStateEquality() async throws {
        let idle1: ViewState<String> = .idle
        let idle2: ViewState<String> = .idle
        let loading: ViewState<String> = .loading
        let loaded: ViewState<String> = .loaded("test")
        let error: ViewState<String> = .error("test error")

        // ViewState is not Equatable, so we just test that we can create different states
        switch idle1 {
        case .idle: break
        default: Issue.record("Expected idle state")
        }

        switch loading {
        case .loading: break
        default: Issue.record("Expected loading state")
        }

        switch loaded {
        case .loaded(let value):
            #expect(value == "test")
        default: Issue.record("Expected loaded state")
        }

        switch error {
        case .error(let message):
            #expect(message == "test error")
        default: Issue.record("Expected error state")
        }
    }
}

// MARK: - Mock Helpers

class MockAPIService: APIServiceProtocol, @unchecked Sendable {
    var shouldFailLogin = false
    var shouldFailCourses = false
    var shouldFailGrades = false
    var shouldFailContents = false
    var mockCourses: [Course] = []
    var mockGrades: GradeResponse?
    var mockSections: [CourseSection] = []

    func login(username: String, password: String) async throws -> AuthTokenResponse {
        if shouldFailLogin {
            throw APIError.serverError("Invalid credentials")
        }
        return AuthTokenResponse(
            token: "mock_token_123",
            privatetoken: "mock_private_456",
            error: nil,
            errorcode: nil
        )
    }

    func getEnrolledCourses(token: String, userId: Int, forceRefresh: Bool = false) async throws -> [Course] {
        if shouldFailCourses {
            throw APIError.networkError(NSError(domain: "test", code: -1))
        }
        return mockCourses.isEmpty ? [
            Course(
                id: 1,
                fullname: "Test Course 1",
                shortname: "TC1",
                progress: 75.0,
                courseimage: nil,
                overviewfiles: nil
            ),
            Course(
                id: 2,
                fullname: "Test Course 2",
                shortname: "TC2",
                progress: 50.0,
                courseimage: nil,
                overviewfiles: nil
            )
        ] : mockCourses
    }

    func getGradeItems(token: String, userId: Int, courseId: Int? = nil) async throws -> GradeResponse {
        if shouldFailGrades {
            throw APIError.networkError(NSError(domain: "test", code: -1))
        }
        return mockGrades ?? GradeResponse(usergrades: [], warnings: nil)
    }

    func getCourseContents(token: String, courseId: Int) async throws -> [CourseSection] {
        if shouldFailContents {
            throw APIError.networkError(NSError(domain: "test", code: -1))
        }
        return mockSections.isEmpty ? [
            CourseSection(
                id: 1,
                name: "Week 1",
                summary: "Introduction",
                modules: [
                    CourseModule(
                        id: 10,
                        name: "Assignment 1",
                        modname: "assign",
                        modplural: "Assignments",
                        description: "First assignment"
                    )
                ]
            )
        ] : mockSections
    }

    func clearCache() {}
}

protocol APIServiceProtocol {
    func login(username: String, password: String) async throws -> AuthTokenResponse
    func getEnrolledCourses(token: String, userId: Int, forceRefresh: Bool) async throws -> [Course]
    func getGradeItems(token: String, userId: Int, courseId: Int?) async throws -> GradeResponse
    func getCourseContents(token: String, courseId: Int) async throws -> [CourseSection]
    func clearCache()
}

extension APIService: APIServiceProtocol {}


struct KeychainServiceTests {
    private let keychain = KeychainService.shared

    @Test func saveAndRetrieve() async throws {
        let key = "test_save_retrieve"
        let value = "test_value_123"
        keychain.save(key: key, value: value)
        #expect(keychain.retrieve(key: key) == value)
        keychain.delete(key: key)
    }

    @Test func retrieveMissingKeyReturnsNil() async throws {
        let key = "test_nonexistent_key_\(UUID().uuidString)"
        #expect(keychain.retrieve(key: key) == nil)
    }

    @Test func deleteRemovesValue() async throws {
        let key = "test_delete"
        keychain.save(key: key, value: "to_delete")
        #expect(keychain.delete(key: key) == true)
        #expect(keychain.retrieve(key: key) == nil)
    }

    @Test func saveOverwritesExistingValue() async throws {
        let key = "test_overwrite"
        keychain.save(key: key, value: "first")
        keychain.save(key: key, value: "second")
        #expect(keychain.retrieve(key: key) == "second")
        keychain.delete(key: key)
    }
}

struct AuthManagerTests {
    @Test func loginWithTokenSetsAuthenticationState() async throws {
        let authManager = AuthManager.shared
        await MainActor.run { authManager.logout() } // Reset state

        await MainActor.run { authManager.loginWithToken() }

        await MainActor.run {
            #expect(authManager.token == Constants.preGeneratedToken)
            #expect(authManager.userId == Constants.preGeneratedUserId)
            #expect(authManager.isAuthenticated == true)
            #expect(authManager.isLoading == false)
            #expect(authManager.errorMessage == nil)
        }

        await MainActor.run { authManager.logout() } // Cleanup
    }

    @Test func logoutClearsAuthenticationState() async throws {
        let authManager = AuthManager.shared
        await MainActor.run { authManager.logout() } // Reset state

        await MainActor.run { authManager.loginWithToken() }
        await MainActor.run { authManager.logout() }

        await MainActor.run {
            #expect(authManager.token == "")
            #expect(authManager.userId == 0)
            #expect(authManager.isAuthenticated == false)
            #expect(authManager.errorMessage == nil)
        }
    }

    @Test func loginWithTokenSetsCorrectValues() async throws {
        let authManager = AuthManager.shared
        await MainActor.run {
            authManager.logout() // Reset state
            authManager.loginWithToken()
            #expect(authManager.isAuthenticated == true)
            #expect(authManager.token.isEmpty == false)
            authManager.logout() // Cleanup
        }
    }

    @Test func loginWithTokenPersistsToKeychain() async throws {
        let authManager = AuthManager.shared
        await MainActor.run { authManager.logout() }

        await MainActor.run { authManager.loginWithToken() }

        await MainActor.run {
            #expect(KeychainService.shared.retrieve(key: Constants.keychainTokenKey) == Constants.preGeneratedToken)
            #expect(KeychainService.shared.retrieve(key: Constants.keychainUserIdKey) == String(Constants.preGeneratedUserId))
            authManager.logout()
        }
    }

    @Test func logoutClearsKeychain() async throws {
        let authManager = AuthManager.shared
        await MainActor.run {
            authManager.logout()
            authManager.loginWithToken()
        }

        await MainActor.run { authManager.logout() }

        await MainActor.run {
            #expect(KeychainService.shared.retrieve(key: Constants.keychainTokenKey) == nil)
            #expect(KeychainService.shared.retrieve(key: Constants.keychainUserIdKey) == nil)
        }
    }
}

// MARK: - LoginViewModel Tests

struct LoginViewModelTests {
    @Test func initializationWithDefaults() async throws {
        let viewModel = LoginViewModel()

        #expect(viewModel.username == Constants.demoUsername)
        #expect(viewModel.password == Constants.demoPassword)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func loginWithTokenCallsAuthManager() async throws {
        let viewModel = LoginViewModel()

        viewModel.loginWithToken()

        #expect(viewModel.isLoading == false)

        AuthManager.shared.logout() // Cleanup
    }
}

// MARK: - CoursesViewModel Tests

struct CoursesViewModelTests {
    @Test func initializationStartsInIdleState() async throws {
        let viewModel = CoursesViewModel()

        switch viewModel.state {
        case .idle: break
        default: Issue.record("Expected idle state")
        }
    }

    @Test func loadCoursesUpdatesStateToLoadingThenLoaded() async throws {
        let viewModel = CoursesViewModel()

        switch viewModel.state {
        case .idle: break
        default: Issue.record("Expected initial idle state")
        }
    }
}

// MARK: - GradesViewModel Tests

struct GradesViewModelTests {
    @Test func initializationStartsInIdleState() async throws {
        let viewModel = GradesViewModel()

        switch viewModel.state {
        case .idle: break
        default: Issue.record("Expected idle state")
        }
    }

    @Test func hasMeaningfulGradesWithModItems() async throws {
        let gradeItem = GradeItem(
            id: 1,
            itemname: "Assignment 1",
            itemtype: "mod",
            itemmodule: "assign",
            graderaw: 85.0,
            gradeformatted: "85.0",
            grademin: 0.0,
            grademax: 100.0,
            percentageformatted: "85%",
            feedback: nil
        )

        let userGrade = UserGrade(
            courseid: 123,
            courseidnumber: "C123",
            userid: 456,
            userfullname: "John Doe",
            gradeitems: [gradeItem]
        )

        #expect(GradesViewModel.hasMeaningfulGrades(userGrade) == true)
    }

    @Test func hasMeaningfulGradesWithCourseTotalAndGrade() async throws {
        let courseTotal = GradeItem(
            id: 1,
            itemname: "Course Total",
            itemtype: "course",
            itemmodule: nil,
            graderaw: 85.0,
            gradeformatted: "85.0",
            grademin: 0.0,
            grademax: 100.0,
            percentageformatted: "85%",
            feedback: nil
        )

        let userGrade = UserGrade(
            courseid: 123,
            courseidnumber: "C123",
            userid: 456,
            userfullname: "John Doe",
            gradeitems: [courseTotal]
        )

        #expect(GradesViewModel.hasMeaningfulGrades(userGrade) == true)
    }

    @Test func hasMeaningfulGradesWithCourseTotalNoGrade() async throws {
        let courseTotal = GradeItem(
            id: 1,
            itemname: "Course Total",
            itemtype: "course",
            itemmodule: nil,
            graderaw: nil,
            gradeformatted: "-",
            grademin: 0.0,
            grademax: 100.0,
            percentageformatted: nil,
            feedback: nil
        )

        let userGrade = UserGrade(
            courseid: 123,
            courseidnumber: "C123",
            userid: 456,
            userfullname: "John Doe",
            gradeitems: [courseTotal]
        )

        #expect(GradesViewModel.hasMeaningfulGrades(userGrade) == false)
    }

    @Test func hasMeaningfulGradesWithNoItems() async throws {
        let userGrade = UserGrade(
            courseid: 123,
            courseidnumber: "C123",
            userid: 456,
            userfullname: "John Doe",
            gradeitems: nil
        )

        #expect(GradesViewModel.hasMeaningfulGrades(userGrade) == false)
    }

    @Test func hasMeaningfulGradesWithEmptyItems() async throws {
        let userGrade = UserGrade(
            courseid: 123,
            courseidnumber: "C123",
            userid: 456,
            userfullname: "John Doe",
            gradeitems: []
        )

        #expect(GradesViewModel.hasMeaningfulGrades(userGrade) == false)
    }
}

// MARK: - CourseDetailViewModel Tests

struct CourseDetailViewModelTests {
    @Test func initializationWithCourse() async throws {
        let course = Course(
            id: 1,
            fullname: "Test Course",
            shortname: "TC",
            progress: 75.0,
            courseimage: nil,
            overviewfiles: nil
        )

        let viewModel = CourseDetailViewModel(course: course)

        #expect(viewModel.course.id == 1)
        #expect(viewModel.course.fullname == "Test Course")

        switch viewModel.state {
        case .idle: break
        default: Issue.record("Expected idle state")
        }
    }
}
