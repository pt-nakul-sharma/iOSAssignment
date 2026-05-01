//
//  iOSAssignmentApp.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import SwiftUI

@main
struct iOSAssignmentApp: App {

    init() {
        if CommandLine.arguments.contains("--uitesting-reset-state") {
            KeychainService.shared.clearAll()
            UserDefaults.standard.removeObject(forKey: Constants.userDefaultsAppLaunchedKey)
        }
    }

    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
