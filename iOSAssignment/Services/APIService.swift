//
//  APIService.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
    case unauthorized
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Authentication failed. Please check your credentials."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

final class APIService {

    static let shared = APIService()
    private let session: URLSession
    private var cachedCourses: [Course]?

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config)
    }

    // MARK: - Login

    func login(username: String, password: String) async throws -> AuthTokenResponse {
        var components = URLComponents(string: Constants.baseURL + Constants.loginEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "service", value: "moodle_mobile_app")
        ]

        guard let url = components.url else { throw APIError.invalidURL }

        let (data, _) = try await performRequest(URLRequest(url: url))
        let response = try decode(AuthTokenResponse.self, from: data)

        if let error = response.error {
            throw APIError.serverError(error)
        }

        return response
    }

    // MARK: - Courses

    func getEnrolledCourses(token: String, userId: Int, forceRefresh: Bool = false) async throws -> [Course] {
        if let cached = cachedCourses, !forceRefresh {
            AppLogger.debug("Using cached courses (\(cached.count) courses)")
            return cached
        }

        let url = try buildAPIURL(token: token, function: Constants.wsGetEnrolledCourses, params: [
            "userid": "\(userId)"
        ])

        let (data, _) = try await performRequest(URLRequest(url: url))
        let courses = try decode([Course].self, from: data)
        cachedCourses = courses
        return courses
    }

    func clearCache() {
        cachedCourses = nil
    }

    // MARK: - Course Contents

    func getCourseContents(token: String, courseId: Int) async throws -> [CourseSection] {
        let url = try buildAPIURL(token: token, function: Constants.wsGetCourseContents, params: [
            "courseid": "\(courseId)"
        ])

        let (data, _) = try await performRequest(URLRequest(url: url))
        return try decode([CourseSection].self, from: data)
    }

    // MARK: - Grades

    func getGradeItems(token: String, userId: Int, courseId: Int? = nil) async throws -> GradeResponse {
        var params: [String: String] = [
            "userid": "\(userId)"
        ]
        if let courseId {
            params["courseid"] = "\(courseId)"
        }

        let url = try buildAPIURL(token: token, function: Constants.wsGetGradeItems, params: params)
        let (data, _) = try await performRequest(URLRequest(url: url))
        return try decode(GradeResponse.self, from: data)
    }

    // MARK: - Private Helpers

    private func buildAPIURL(token: String, function: String, params: [String: String] = [:]) throws -> URL {
        var components = URLComponents(string: Constants.baseURL + Constants.apiEndpoint)!
        var queryItems = [
            URLQueryItem(name: "wstoken", value: token),
            URLQueryItem(name: "wsfunction", value: function),
            URLQueryItem(name: "moodlewsrestformat", value: Constants.restFormat)
        ]
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        components.queryItems = queryItems

        guard let url = components.url else { throw APIError.invalidURL }
        return url
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        AppLogger.logRequest(request)
        do {
            let (data, response) = try await session.data(for: request)
            AppLogger.logResponse(response, data: data)
            return (data, response)
        } catch {
            AppLogger.logResponse(nil, data: nil, error: error)
            throw APIError.networkError(error)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: data)
            AppLogger.debug("Decoded \(T.self) successfully")
            return result
        } catch {
            AppLogger.error("Decode failed for \(T.self): \(error)")
            throw APIError.decodingError(error)
        }
    }
}
