//
//  ClientModels.swift
//  ViewClientsModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

// MARK: - Client Request
public struct ClientRequest: Codable {
    let role: String
    
    public init(role: String) {
        self.role = role
    }
}

// MARK: - Client Response
public struct Client: Codable, Identifiable {
    public let id: String
    let name: String
    let address: String
    let schedule: String
    let travelTime: String
    
    public init(id: String, name: String, address: String, schedule: String, travelTime: String) {
        self.id = id
        self.name = name
        self.address = address
        self.schedule = schedule
        self.travelTime = travelTime
    }
}

public struct ClientsResponse: Codable {
    let clients: [Client]
    
    public init(clients: [Client]) {
        self.clients = clients
    }
}

// MARK: - Client Error
public enum ClientError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
    case unauthorized
    case serverError(Int)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
}
