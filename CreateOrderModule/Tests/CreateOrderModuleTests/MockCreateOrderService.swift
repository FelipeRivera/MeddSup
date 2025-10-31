//
//  MockCreateOrderService.swift
//  CreateOrderModuleTests
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation
@testable import CreateOrderModule

final class MockCreateOrderService: @unchecked Sendable, CreateOrderServiceProtocol {
    var shouldSucceed: Bool = true
    var createOrderCalled = false
    var lastRequest: CreateOrderRequest?
    var lastToken: String?
    
    func createOrder(request: CreateOrderRequest, token: String) async throws {
        createOrderCalled = true
        lastRequest = request
        lastToken = token
        
        if !shouldSucceed {
            throw CreateOrderError.serverError(500)
        }
    }
}

