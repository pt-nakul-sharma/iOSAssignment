//
//  iOSAssignmentUITests.swift
//  iOSAssignmentUITests
//
//  Created by Nakul Sharma on 01/05/26.
//

import XCTest

final class iOSAssignmentUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting-reset-state"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helper

    @MainActor
    private func launchAndLoginWithDemoToken() {
        app.launch()

        let demoTokenButton = app.buttons["Use Demo Token"]
        XCTAssertTrue(demoTokenButton.waitForExistence(timeout: 5), "Demo token button should appear after splash screen")
        demoTokenButton.tap()

        let coursesTitle = app.staticTexts["My Courses"]
        XCTAssertTrue(coursesTitle.waitForExistence(timeout: 10), "Courses view should appear after demo login")
    }

    // MARK: - Tests

    @MainActor
    func testDemoTokenLoginShowsCourses() throws {
        launchAndLoginWithDemoToken()
    }

    @MainActor
    func testTabSwitching() throws {
        launchAndLoginWithDemoToken()

        app.tabBars.buttons["Grades"].tap()
        XCTAssertTrue(app.staticTexts["Grades"].waitForExistence(timeout: 5), "Grades tab should be visible")

        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Profile"].waitForExistence(timeout: 5), "Profile tab should be visible")
    }

    @MainActor
    func testLogoutFlow() throws {
        launchAndLoginWithDemoToken()

        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Profile"].waitForExistence(timeout: 5))

        let signOutButton = app.buttons["Sign Out"]
        XCTAssertTrue(signOutButton.waitForExistence(timeout: 5))
        signOutButton.tap()

        let demoTokenButton = app.buttons["Use Demo Token"]
        XCTAssertTrue(demoTokenButton.waitForExistence(timeout: 5), "Login view should reappear after logout")
    }

    @MainActor
    func testNavigateToCourseDetail() throws {
        launchAndLoginWithDemoToken()

        let firstCourse = app.scrollViews.firstMatch.buttons.firstMatch
        guard firstCourse.waitForExistence(timeout: 15) else {
            throw XCTSkip("No enrolled courses available for UI test navigation")
        }

        firstCourse.tap()

        let backButton = app.buttons["My Courses"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button to Courses should appear after navigating to course detail")
    }

    @MainActor
    func testLoginPersistsAcrossAppRestarts() throws {
        // First launch with reset state: log in
        app.launch()

        let demoTokenButton = app.buttons["Use Demo Token"]
        XCTAssertTrue(demoTokenButton.waitForExistence(timeout: 5))
        demoTokenButton.tap()

        let coursesTitle = app.staticTexts["My Courses"]
        XCTAssertTrue(coursesTitle.waitForExistence(timeout: 10))

        // Terminate and relaunch without reset argument
        app.terminate()

        let relaunchedApp = XCUIApplication()
        relaunchedApp.launch()

        // Should land directly on courses (still authenticated)
        XCTAssertTrue(relaunchedApp.staticTexts["My Courses"].waitForExistence(timeout: 10),
                      "User should remain logged in after app restart")
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
