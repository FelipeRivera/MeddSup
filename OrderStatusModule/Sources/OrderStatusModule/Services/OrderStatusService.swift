//
//  OrderStatusService.swift
//  OrderStatusModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

public protocol OrderStatusServiceProtocol: Sendable {
    func fetchOrderStatus(request: OrderStatusRequest) async throws -> OrderStatusResponse
}

public class OrderStatusService: @unchecked Sendable, OrderStatusServiceProtocol {
    private let baseURL: String
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    public func fetchOrderStatus(request: OrderStatusRequest) async throws -> OrderStatusResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Mock data based on the image provided
        let mockOrders = [
            OrderStatus(id: "1", orderId: "12345", statusId: "En preparacion"),
            OrderStatus(id: "2", orderId: "67890", statusId: "transito"),
            OrderStatus(id: "3", orderId: "54321", statusId: "entregado"),
            OrderStatus(id: "4", orderId: "98765", statusId: "pendiente"),
            OrderStatus(id: "5", orderId: "11111", statusId: "En preparacion"),
            OrderStatus(id: "6", orderId: "22222", statusId: "transito")
        ]
        
        return OrderStatusResponse(orders: mockOrders)
    }
}

// MARK: - Mock Service for Testing
public class MockOrderStatusService: @unchecked Sendable, OrderStatusServiceProtocol {
    private let mockResponse: OrderStatusResponse
    private let shouldFail: Bool
    private let error: OrderStatusError?
    
    public init(mockResponse: OrderStatusResponse = OrderStatusResponse(orders: []), shouldFail: Bool = false, error: OrderStatusError? = nil) {
        self.mockResponse = mockResponse
        self.shouldFail = shouldFail
        self.error = error
    }
    
    public func fetchOrderStatus(request: OrderStatusRequest) async throws -> OrderStatusResponse {
        if shouldFail {
            throw error ?? OrderStatusError.networkError("Mock error")
        }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        return mockResponse
    }
}
