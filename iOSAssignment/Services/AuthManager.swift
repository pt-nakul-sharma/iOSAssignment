//
//  AuthManager.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import Foundation

@Observable
final class AuthManager {

    var token: String = ""
    var userId: Int = 0
    var isAuthenticated: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?

    static let shared = AuthManager()

    private let keychain = KeychainService.shared

    private init() {
        checkFreshInstall()
        restoreSession()
    }

    // MARK: - Fresh install detection

    private func checkFreshInstall() {
        let defaults = UserDefaults.standard
        let hasLaunched = defaults.bool(forKey: Constants.userDefaultsAppLaunchedKey)
        AppLogger.debug("Fresh install check: hasLaunched = \(hasLaunched)")

        if !hasLaunched {
            // First launch or app was reinstalled: clear any stale Keychain data
            AppLogger.debug("Fresh install detected — clearing Keychain")
            keychain.clearAll()
            defaults.set(true, forKey: Constants.userDefaultsAppLaunchedKey)
        }
    }

    // MARK: - Restore session from Keychain

    private func restoreSession() {
        let savedToken = keychain.retrieve(key: Constants.keychainTokenKey)
        let savedUserIdString = keychain.retrieve(key: Constants.keychainUserIdKey)
        AppLogger.debug("Restore session: token present = \(savedToken != nil), userId present = \(savedUserIdString != nil)")

        if let savedToken = savedToken,
           !savedToken.isEmpty,
           let savedUserIdString = savedUserIdString,
           let savedUserId = Int(savedUserIdString) {
            self.token = savedToken
            self.userId = savedUserId
            self.isAuthenticated = true
            AppLogger.debug("Session restored successfully")
        } else {
            AppLogger.debug("No valid session found in Keychain")
        }
    }

    // MARK: - Login via credentials

    func login(username: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await APIService.shared.login(username: username, password: password)
            guard let token = response.token else {
                errorMessage = response.error ?? "Login failed. No token received."
                isLoading = false
                return
            }
            self.token = token
            // After login, we need the userId. Use the pre-generated one since
            // the token API doesn't return it directly. For a real app, we'd call
            // core_webservice_get_site_info to retrieve the userid.
            self.userId = Constants.preGeneratedUserId
            self.isAuthenticated = true
            self.isLoading = false
            persistSession()
        } catch let error as APIError {
            errorMessage = error.errorDescription
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Login via pre-generated token

    func loginWithToken() {
        self.token = Constants.preGeneratedToken
        self.userId = Constants.preGeneratedUserId
        self.isAuthenticated = true
        persistSession()
    }

    // MARK: - Persist session to Keychain

    private func persistSession() {
        let tokenSaved = keychain.save(key: Constants.keychainTokenKey, value: token)
        let userIdSaved = keychain.save(key: Constants.keychainUserIdKey, value: String(userId))
        AppLogger.debug("Persist session: tokenSaved = \(tokenSaved), userIdSaved = \(userIdSaved)")
    }

    // MARK: - Logout

    func logout() {
        token = ""
        userId = 0
        isAuthenticated = false
        errorMessage = nil
        keychain.delete(key: Constants.keychainTokenKey)
        keychain.delete(key: Constants.keychainUserIdKey)
        AppLogger.debug("User logged out — session cleared")
    }
}
