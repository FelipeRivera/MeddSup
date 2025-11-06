//
//  CustomerRegistrationService.swift
//  customerRegistrationModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

public protocol CustomerRegistrationServiceProtocol: Sendable {
    func registerCustomer(request: CustomerRegistrationRequest, token: String) async throws -> CustomerRegistrationResponse
}

public final class CustomerRegistrationService: @unchecked Sendable, CustomerRegistrationServiceProtocol {
    private let baseURL: String
    private let urlSession: URLSession
    
    public init(baseURL: String, urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }
    
    public func registerCustomer(request: CustomerRegistrationRequest, token: String) async throws -> CustomerRegistrationResponse {
        guard let url = URL(string: baseURL) else {
            throw CustomerRegistrationError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CustomerRegistrationError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorData = try? JSONDecoder().decode([String: String].self, from: data),
               let message = errorData["message"] {
                throw CustomerRegistrationError.serverError(httpResponse.statusCode, message: message)
            }
            throw CustomerRegistrationError.serverError(httpResponse.statusCode, message: nil)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(CustomerRegistrationResponse.self, from: data)
        } catch {
            // If decoding fails, try to return a success response
            return CustomerRegistrationResponse(success: true, message: nil, clientId: nil)
        }
    }
}

// MARK: - Errors
public enum CustomerRegistrationError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int, message: String?)
    case networkError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code, let message):
            if let message = message {
                return message
            }
            return "Server error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

