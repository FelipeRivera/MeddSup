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
    
    @Test func testLoginRequestEncoding() throws {
        let request = LoginRequest(email: "testuser", password: "testpass")
        
        let jsonData = try JSONEncoder().encode(request)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        #expect(jsonString != nil)
        #expect(jsonString?.contains("testuser") == true)
        #expect(jsonString?.contains("testpass") == true)
    }
    
    @Test func testLoginRequestDecoding() throws {
        let jsonString = """
        {
            "email": "testuser",
            "password": "testpass"
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        let request = try JSONDecoder().decode(LoginRequest.self, from: jsonData)
        
        #expect(request.email == "testuser")
        #expect(request.password == "testpass")
    }
    
    // MARK: - LoginResponse Tests
    
    @Test func testLoginResponseInitialization() {
        let response = LoginResponse(accessToken: "test_token_123")
        
        #expect(response.accessToken == "test_token_123")
    }
    
    @Test func testLoginResponseEncoding() throws {
        let response = LoginResponse(accessToken: "test_token_123")
        
        let jsonData = try JSONEncoder().encode(response)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        #expect(jsonString != nil)
        #expect(jsonString?.contains("access_token") == true)
        #expect(jsonString?.contains("test_token_123") == true)
    }
    
    @Test func testLoginResponseDecoding() throws {
        let jsonString = """
        {
            "access_token": "test_token_123"
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        let response = try JSONDecoder().decode(LoginResponse.self, from: jsonData)
        
        #expect(response.accessToken == "test_token_123")
    }
    
    // MARK: - Edge Cases Tests
    
    @Test func testLoginRequestWithEmptyValues() {
        let request = LoginRequest(email: "", password: "")
        
        #expect(request.email == "")
        #expect(request.password == "")
    }
    
    @Test func testLoginResponseWithEmptyToken() {
        let response = LoginResponse(accessToken: "")
        
        #expect(response.accessToken == "")
    }
    
    @Test func testLoginRequestWithSpecialCharacters() {
        let email = "user@example.com"
        let password = "pass@word#123"
        let request = LoginRequest(email: email, password: password)
        
        #expect(request.email == email)
        #expect(request.password == password)
    }
}
