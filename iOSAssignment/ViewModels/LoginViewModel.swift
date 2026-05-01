//
//  LoginViewModel.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import Foundation

@Observable
final class LoginViewModel {

    var username: String = Constants.demoUsername
    var password: String = Constants.demoPassword

    private let authManager: AuthManager

    init(authManager: AuthManager = .shared) {
        self.authManager = authManager
    }

    var isLoading: Bool {
        authManager.isLoading
    }

    var errorMessage: String? {
        authManager.errorMessage
    }

    func login() async {
        await authManager.login(username: username, password: password)
    }

    func loginWithToken() {
        authManager.loginWithToken()
    }
}
