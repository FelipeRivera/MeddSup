//
//  OrderStatusModuleTests.swift
//  OrderStatusModuleTests
//
//  Created by Felipe Rivera on 3/09/25.
//

import XCTest
@testable import OrderStatusModule

final class OrderStatusModuleTests: XCTestCase {
    
    func testOrderStatusCreation() throws {
        let order = OrderStatus(id: "1", orderId: "12345", statusId: "En preparacion")
        
        XCTAssertEqual(order.id, "1")
        XCTAssertEqual(order.orderId, "12345")
        XCTAssertEqual(order.statusId, "En preparacion")
    }
    
    func testOrderStatusTypeFromStatusId() throws {
        let enPreparacion = OrderStatusType.from(statusId: "En preparacion")
        let transito = OrderStatusType.from(statusId: "transito")
        let entregado = OrderStatusType.from(statusId: "entregado")
        let pendiente = OrderStatusType.from(statusId: "pendiente")
        let invalid = OrderStatusType.from(statusId: "invalid")
        
        XCTAssertEqual(enPreparacion, .enPreparacion)
        XCTAssertEqual(transito, .transito)
        XCTAssertEqual(entregado, .entregado)
        XCTAssertEqual(pendiente, .pendiente)
        XCTAssertNil(invalid)
    }
    
    func testOrderStatusTypeRawValues() throws {
        XCTAssertEqual(OrderStatusType.enPreparacion.rawValue, "En preparacion")
        XCTAssertEqual(OrderStatusType.transito.rawValue, "transito")
        XCTAssertEqual(OrderStatusType.entregado.rawValue, "entregado")
        XCTAssertEqual(OrderStatusType.pendiente.rawValue, "pendiente")
    }
    
    func testOrderStatusTypeStatusColors() throws {
        XCTAssertEqual(OrderStatusType.enPreparacion.statusColor, "orange")
        XCTAssertEqual(OrderStatusType.transito.statusColor, "green")
        XCTAssertEqual(OrderStatusType.entregado.statusColor, "mutedGreen")
        XCTAssertEqual(OrderStatusType.pendiente.statusColor, "gray")
    }
    
    func testMockOrderStatusService() async throws {
        let mockOrders = [
            OrderStatus(id: "1", orderId: "12345", statusId: "En preparacion"),
            OrderStatus(id: "2", orderId: "67890", statusId: "transito")
        ]
        let mockResponse = OrderStatusResponse(orders: mockOrders)
        let mockService = MockOrderStatusService(mockResponse: mockResponse)
        
        let request = OrderStatusRequest(accessToken: "test_token", role: "user")
        let response = try await mockService.fetchOrderStatus(request: request)
        
        XCTAssertEqual(response.orders.count, 2)
        XCTAssertEqual(response.orders[0].orderId, "12345")
        XCTAssertEqual(response.orders[1].orderId, "67890")
    }
    
    func testMockOrderStatusServiceFailure() async throws {
        let mockService = MockOrderStatusService(shouldFail: true, error: .networkError("Test error"))
        
        let request = OrderStatusRequest(accessToken: "test_token", role: "user")
        
        do {
            _ = try await mockService.fetchOrderStatus(request: request)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is OrderStatusError)
        }
    }
}