//
//  ClientService.swift
//  ViewClientsModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation
import Combine

public protocol ClientServiceProtocol {
    func fetchClients(baseURL: String, token: String, role: String) -> AnyPublisher<[Client], ClientError>
}

public class ClientService: ClientServiceProtocol {
    public init() {}
    
    public func fetchClients(baseURL: String, token: String, role: String) -> AnyPublisher<[Client], ClientError> {
        guard let url = URL(string: "\(baseURL)/clients") else {
            return Fail(error: ClientError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ClientRequest(role: role)
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            return Fail(error: ClientError.networkError("Failed to encode request body"))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ClientsResponse.self, decoder: JSONDecoder())
            .map(\.clients)
            .mapError { error in
                if error is DecodingError {
                    return ClientError.decodingError
                } else if let urlError = error as? URLError {
                    return ClientError.networkError(urlError.localizedDescription)
                } else {
                    return ClientError.networkError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Static Mock Service (non-network)
public final class MockClientService: ClientServiceProtocol {
    
    public init() {}
    
    public func fetchClients(baseURL: String, token: String, role: String) -> AnyPublisher<[Client], ClientError> {
        let mockClients = [
            Client(
                id: "1",
                name: "Cliente1",
                address: "Calle Falsa 123, Ciudad",
                schedule: "09:00 - 10:00",
                travelTime: "15 minutos"
            ),
            Client(
                id: "2",
                name: "Cliente2",
                address: "Avenida Siempre Viva 742, Ciudad",
                schedule: "11:00 - 12:00",
                travelTime: "20 minutos"
            ),
            Client(
                id: "3",
                name: "Cliente3",
                address: "Plaza Mayor 456, Ciudad",
                schedule: "13:00 - 14:00",
                travelTime: "10 minutos"
            ),
            Client(
                id: "4",
                name: "Cliente4",
                address: "Calle Principal 789, Miami",
                schedule: "15:00 - 16:00",
                travelTime: "25 minutos"
            ),
            Client(
                id: "5",
                name: "Cliente5",
                address: "Avenida Central 321, Ciudad",
                schedule: "17:00 - 18:00",
                travelTime: "12 minutos"
            )
        ]
        
        return Just(mockClients)
            .setFailureType(to: ClientError.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Mock Service for Testing
#if DEBUG
public final class SimpleMockClientService: ClientServiceProtocol, @unchecked Sendable {
    public var result: Result<[Client], ClientError>
    
    public init(result: Result<[Client], ClientError> = .success([])) {
        self.result = result
    }
    
    public func fetchClients(baseURL: String, token: String, role: String) -> AnyPublisher<[Client], ClientError> {
        switch result {
        case .success(let clients):
            return Just(clients)
                .setFailureType(to: ClientError.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
#endif
