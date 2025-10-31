//
//  OrderStatusService.swift
//  OrderStatusModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

public protocol OrderStatusServiceProtocol: Sendable {
    func fetchOrderStatus(request: OrderStatusRequest) async throws -> [OrderStatus]
}

public class OrderStatusService: @unchecked Sendable, OrderStatusServiceProtocol {
    private let baseURL: String
    private let session: URLSession
    
    public init(baseURL: String, session: URLSession = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    public func fetchOrderStatus(request: OrderStatusRequest) async throws -> [OrderStatus] {
        // Use the baseURL that is passed to the service
        guard let url = URL(string: baseURL) else {
            throw OrderStatusError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("Bearer \(request.accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("cust-1", forHTTPHeaderField: "X-Customer-Id")
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OrderStatusError.networkError("Invalid response")
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    // The API returns an array directly
                    let orders = try JSONDecoder().decode([OrderStatus].self, from: data)
                    return orders
                } catch {
                    print("Decoding error: \(error)")
                    throw OrderStatusError.decodingError
                }
            case 401:
                throw OrderStatusError.unauthorized
            case 403:
                throw OrderStatusError.invalidToken
            default:
                throw OrderStatusError.serverError(httpResponse.statusCode)
            }
        } catch let error as OrderStatusError {
            throw error
        } catch {
            throw OrderStatusError.networkError(error.localizedDescription)
        }
    }
}

// MARK: - Mock Service for Testing
public class MockOrderStatusService: @unchecked Sendable, OrderStatusServiceProtocol {
    private let mockOrders: [OrderStatus]
    private let shouldFail: Bool
    private let error: OrderStatusError?
    
    public init(mockOrders: [OrderStatus] = [], shouldFail: Bool = false, error: OrderStatusError? = nil) {
        self.mockOrders = mockOrders
        self.shouldFail = shouldFail
        self.error = error
    }
    
    public func fetchOrderStatus(request: OrderStatusRequest) async throws -> [OrderStatus] {
        if shouldFail {
            throw error ?? OrderStatusError.networkError("Mock error")
        }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        return mockOrders
    }
    
    // Convenience initializer for creating mock data
    public static func createMockService() -> MockOrderStatusService {
        let mockOrders = [
            OrderStatus(
                orderId: "ORD-1001", 
                statusId: "transito", 
                createdAt: "2025-10-28T16:29:25.060500+00:00",
                items: [],
                monto: 0.0
            ),
            OrderStatus(
                orderId: "ORD-1002", 
                statusId: "En preparacion", 
                createdAt: "2025-10-28T15:30:00.000000+00:00",
                items: [],
                monto: 150.0
            ),
            OrderStatus(
                orderId: "ORD-1003", 
                statusId: "entregado", 
                createdAt: "2025-10-27T14:20:00.000000+00:00",
                items: [],
                monto: 75.5
            )
        ]
        
        return MockOrderStatusService(mockOrders: mockOrders)
    }
}
