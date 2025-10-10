//
//  LoginModels.swift
//  LoginModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

// MARK: - Login Request
public struct LoginRequest: Sendable, Codable {
    public let user: String
    public let password: String
    
    public init(user: String, password: String) {
        self.user = user
        self.password = password
    }
}

// MARK: - Login Response
public struct LoginResponse: Sendable, Codable {
    public let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
    
    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}

// MARK: - Login Error
public enum LoginError: Sendable, Error, LocalizedError {
    case invalidCredentials
    case networkError(String)
    case invalidResponse
    case decodingError
    
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return .localized("error.invalid.credentials")
        case .networkError(let message):
            return .localized("error.network", arguments: message)
        case .invalidResponse:
            return .localized("error.invalid.response")
        case .decodingError:
            return .localized("error.decoding")
        }
    }
}
