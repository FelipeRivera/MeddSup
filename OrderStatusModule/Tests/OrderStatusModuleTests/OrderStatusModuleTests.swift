//
//  OrderStatusModuleTests.swift
//  OrderStatusModuleTests
//
//  Created by Felipe Rivera on 3/09/25.
//

import Testing
@testable import OrderStatusModule

struct OrderStatusBusinessLogicTests {
    // MARK: - Core Business Logic Tests
    @Test("OrderStatus model creation and identification")
    func testOrderStatusModel() async {
        let order = OrderStatus(
            orderId: "ORD-12345",
            statusId: "En preparacion",
            createdAt: "2025-01-03T10:00:00.000Z",
            items: [],
            monto: 150.0
        )
        
        #expect(order.id == "ORD-12345")
        #expect(order.orderId == "ORD-12345")
        #expect(order.statusId == "En preparacion")
        #expect(order.monto == 150.0)
    }
    
    @Test("OrderStatusType mapping from status ID")
    func testOrderStatusTypeMapping() async {
        let enPreparacion = OrderStatusType.from(statusId: "En preparacion")
        let transito = OrderStatusType.from(statusId: "transito")
        let entregado = OrderStatusType.from(statusId: "entregado")
        let pendiente = OrderStatusType.from(statusId: "pendiente")
        let invalid = OrderStatusType.from(statusId: "invalid")
        
        #expect(enPreparacion == .enPreparacion)
        #expect(transito == .transito)
        #expect(entregado == .entregado)
        #expect(pendiente == .pendiente)
        #expect(invalid == nil)
    }
    
    @Test("Mock service returns correct data without network calls")
    func testMockServiceDataRetrieval() async throws {
        let mockOrders = [
            OrderStatus(
                orderId: "ORD-12345",
                statusId: "En preparacion",
                createdAt: "2025-01-03T10:00:00.000Z",
                items: [],
                monto: 150.0
            ),
            OrderStatus(
                orderId: "ORD-67890",
                statusId: "transito",
                createdAt: "2025-01-03T11:00:00.000Z",
                items: [],
                monto: 75.5
            )
        ]
        
        let mockService = MockOrderStatusService(mockOrders: mockOrders)
        let request = OrderStatusRequest(accessToken: "test_token", role: "user")
        
        let orders = try await mockService.fetchOrderStatus(request: request)
        
        #expect(orders.count == 2)
        #expect(orders[0].orderId == "ORD-12345")
        #expect(orders[1].orderId == "ORD-67890")
    }
    
    @Test("Mock service handles error cases")
    func testMockServiceErrorHandling() async {
        let mockService = MockOrderStatusService(
            mockOrders: [],
            shouldFail: true,
            error: .networkError("Test error")
        )
        
        let request = OrderStatusRequest(accessToken: "test_token", role: "user")
        
        await #expect(throws: OrderStatusError.self) {
            try await mockService.fetchOrderStatus(request: request)
        }
    }
    
    @Test("OrderStatusRequest creation")
    func testOrderStatusRequestCreation() async {
        let request = OrderStatusRequest(accessToken: "test_token", role: "admin")
        
        #expect(request.accessToken == "test_token")
        #expect(request.role == "admin")
    }
    
    @Test("OrderStatusError cases")
    func testOrderStatusErrorCases() async {
        let networkError = OrderStatusError.networkError("Network failed")
        let invalidURL = OrderStatusError.invalidURL
        let unauthorized = OrderStatusError.unauthorized
        let invalidToken = OrderStatusError.invalidToken
        let decodingError = OrderStatusError.decodingError
        let serverError = OrderStatusError.serverError(500)
        
        // Test that all error cases can be created
        #expect(networkError != nil)
        #expect(invalidURL != nil)
        #expect(unauthorized != nil)
        #expect(invalidToken != nil)
        #expect(decodingError != nil)
        #expect(serverError != nil)
    }
}
