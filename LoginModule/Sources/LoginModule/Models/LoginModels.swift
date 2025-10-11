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
    public let expiresIn: Int?
    public let role: String?
    public let tokenType: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case role
        case tokenType = "token_type"
    }

    // Full initializer
    public init(accessToken: String, expiresIn: Int? = nil, role: String? = nil, tokenType: String? = nil) {
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.role = role
        self.tokenType = tokenType
    }

    // Convenience computed property for expiration date (now + expiresIn)
    public var expirationDate: Date? {
        guard let expiresIn = expiresIn else { return nil }
        return Date().addingTimeInterval(TimeInterval(expiresIn))
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
