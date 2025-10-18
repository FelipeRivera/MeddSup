//
//  ModelsTests.swift
//  LoginModuleTests
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation
import Testing
@testable import LoginModule

struct ModelsTests {
    
    // MARK: - LoginRequest Tests
    
    @Test func testLoginRequestInitialization() {
        let request = LoginRequest(email: "testuser", password: "testpass")
        
        #expect(request.email == "testuser")
        #expect(request.password == "testpass")
    }
    
    // MARK: - LoginResponse Tests
    
    @Test func testLoginResponseInitialization() {
        let response = LoginResponse(accessToken: "test_token_123")
        
        #expect(response.accessToken == "test_token_123")
    }
}
