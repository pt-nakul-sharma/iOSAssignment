//
//  Constants.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import Foundation

enum Constants {
    static let baseURL = "https://moodle.itcorner.qzz.io"
    static let apiEndpoint = "/webservice/rest/server.php"
    static let loginEndpoint = "/login/token.php"

    // Pre-generated token (Option B)
    static let preGeneratedToken = "c269d73b8ec3265227714bf37f4dd2e4"
    static let preGeneratedUserId = 1003

    // Demo credentials (Option A)
    static let demoUsername = "student1"
    static let demoPassword = "Demo@12345"

    // Moodle web service functions
    static let wsGetEnrolledCourses = "core_enrol_get_users_courses"
    static let wsGetCourseContents = "core_course_get_contents"
    static let wsGetGradeItems = "gradereport_user_get_grade_items"

    // REST format
    static let restFormat = "json"

    // Keychain keys
    static let keychainTokenKey = "com.iOSAssignment.authToken"
    static let keychainUserIdKey = "com.iOSAssignment.userId"

    // UserDefaults keys
    static let userDefaultsAppLaunchedKey = "com.iOSAssignment.appHasBeenLaunched"

    // Keychain access group (Keychain Sharing)
    static let keychainAccessGroup = "com.tecorb.iOSAssignment"
}
