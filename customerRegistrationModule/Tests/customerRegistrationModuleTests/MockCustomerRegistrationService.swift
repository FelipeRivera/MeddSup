//
//  MockCustomerRegistrationService.swift
//  customerRegistrationModuleTests
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation
@testable import customerRegistrationModule

final class MockCustomerRegistrationService: @unchecked Sendable, CustomerRegistrationServiceProtocol {
    var shouldSucceed: Bool = true
    var mockResponse: CustomerRegistrationResponse?
    var mockError: Error?
    var registerCustomerCallCount: Int = 0
    var lastRequest: CustomerRegistrationRequest?
    
    init(shouldSucceed: Bool = true, mockResponse: CustomerRegistrationResponse? = nil, mockError: Error? = nil) {
        self.shouldSucceed = shouldSucceed
        self.mockResponse = mockResponse
        self.mockError = mockError
    }
    
    func registerCustomer(request: CustomerRegistrationRequest, token: String) async throws -> CustomerRegistrationResponse {
        registerCustomerCallCount += 1
        lastRequest = request
        
        if shouldSucceed {
            return mockResponse ?? CustomerRegistrationResponse(success: true, message: "Success", clientId: "123")
        } else {
            throw mockError ?? CustomerRegistrationError.serverError(500, message: "Test error")
        }
    }
}
