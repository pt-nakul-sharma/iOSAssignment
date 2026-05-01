//
//  KeychainService.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import Foundation
import Security

enum KeychainError: Error {
    case itemNotFound
    case duplicateItem
    case invalidStatus(OSStatus)
    case conversionFailed
}

final class KeychainService {

    static let shared = KeychainService()

    private init() {}

    // MARK: - Save

    @discardableResult
    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            AppLogger.error("Keychain save failed: unable to encode value for key \(key)")
            return false
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        // Delete any existing item first to avoid duplicates
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            AppLogger.debug("Keychain saved key: \(key)")
            return true
        } else {
            AppLogger.error("Keychain save failed for key \(key) with status: \(status)")
            return false
        }
    }

    // MARK: - Retrieve

    func retrieve(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            if status != errSecItemNotFound {
                AppLogger.error("Keychain retrieve failed for key \(key) with status: \(status)")
            }
            return nil
        }

        AppLogger.debug("Keychain retrieved key: \(key)")
        return value
    }

    // MARK: - Delete

    @discardableResult
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        let success = status == errSecSuccess || status == errSecItemNotFound
        if success {
            AppLogger.debug("Keychain deleted key: \(key)")
        } else {
            AppLogger.error("Keychain delete failed for key \(key) with status: \(status)")
        }
        return success
    }

    // MARK: - Clear All

    func clearAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess || status == errSecItemNotFound {
            AppLogger.debug("Keychain cleared all generic password items")
        } else {
            AppLogger.error("Keychain clearAll failed with status: \(status)")
        }
    }
}
