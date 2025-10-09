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
    
    public init(baseURL: String = "http://localhost:8080") {
        self.baseURL = baseURL
        self.session = URLSession.shared
    }
    
    public func login(user: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw LoginError.networkError("URL inválida")
        }
        
        let request = LoginRequest(user: user, password: password)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
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
                throw LoginError.networkError("Error del servidor: \(httpResponse.statusCode)")
            }
        } catch let error as LoginError {
            throw error
        } catch {
            throw LoginError.networkError(error.localizedDescription)
        }
    }
}
