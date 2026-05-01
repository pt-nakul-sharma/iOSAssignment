//
//  Logger.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import Foundation
import os

enum AppLogger {

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.tecorb.iOSAssignment"
    private static let networkLogger = os.Logger(subsystem: subsystem, category: "Network")

    // MARK: - Network Logging

    static func logRequest(_ request: URLRequest) {
        #if DEBUG
        networkLogger.debug("➡️ REQUEST: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "nil")")
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            networkLogger.debug("   Headers: \(headers.description)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            networkLogger.debug("   Body: \(bodyString)")
        }
        #endif
    }

    static func logResponse(_ response: URLResponse?, data: Data?, error: Error? = nil) {
        #if DEBUG
        if let httpResponse = response as? HTTPURLResponse {
            let statusEmoji = (200...299).contains(httpResponse.statusCode) ? "✅" : "❌"
            print("\(statusEmoji) RESPONSE: \(httpResponse.statusCode) \(httpResponse.url?.absoluteString ?? "nil")")
        }
        if let data = data, let jsonString = prettyPrintJSON(data) {
            print("   Body: \(jsonString)")
        }
        if let error = error {
            print("🔴 Error: \(error.localizedDescription)")
        }
        #endif
    }

    // MARK: - General Logging

    static func debug(_ message: String) {
        #if DEBUG
        networkLogger.debug("🔹 \(message)")
        #endif
    }

    static func error(_ message: String) {
        #if DEBUG
        networkLogger.error("🔴 \(message)")
        #endif
    }

    // MARK: - Helpers

    private static func prettyPrintJSON(_ data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
              let string = String(data: prettyData, encoding: .utf8) else {
            return String(data: data, encoding: .utf8)
        }
        return string
    }
}
