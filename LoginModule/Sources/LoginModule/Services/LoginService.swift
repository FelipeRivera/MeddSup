//
//  LoginService.swift
//  LoginModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

public class LoginService: @unchecked Sendable {
    private let baseURL: String
    private let session: URLSession
    private let backgroundQueue = DispatchQueue(label: "com.meddsup.login.service", qos: .userInitiated)
    
    public init(baseURL: String = "http://localhost:8080") {
        self.baseURL = baseURL
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.httpMaximumConnectionsPerHost = 4
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        self.session = URLSession(configuration: config)
    }
    
    public func login(user: String, password: String) async throws -> LoginResponse {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: LoginError.networkError(.localized("error.service.deallocated")))
                    return
                }
                
                Task {
                    do {
                        let result = try await self.performLogin(user: user, password: password)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    private func performLogin(user: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw LoginError.networkError(.localized("error.invalid.url"))
        }
        
        let request = LoginRequest(email: user, password: password)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
        } catch {
            throw LoginError.decodingError
        }
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LoginError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    return loginResponse
                } catch {
                    throw LoginError.decodingError
                }
            case 401:
                throw LoginError.invalidCredentials
            default:
                throw LoginError.networkError(.localized("error.server", arguments: httpResponse.statusCode))
            }
        } catch let error as LoginError {
            throw error
        } catch {
            throw LoginError.networkError(error.localizedDescription)
        }
    }
}
