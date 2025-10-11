//
//  IntegrationTests.swift
//  LoginModuleTests
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation
import Testing
@testable import LoginModule

@MainActor
struct IntegrationTests {
    
    // MARK: - Module Creation Tests
    
    @Test func testLoginModuleCreation() {
        let viewModel = LoginModule.createLoginViewModel(baseURL: "http://test.com")
        
        #expect(viewModel != nil)
        #expect(viewModel.isLoggedIn == false)
        #expect(viewModel.isLoading == false)
    }
    
    @Test func testLoginModuleWithDefaultURL() {
        let viewModel = LoginModule.createLoginViewModel()
        
        #expect(viewModel != nil)
        #expect(viewModel.isLoggedIn == false)
    }
    
    @Test func testLoginServiceCreation() {
        let service = LoginModule.createLoginService(baseURL: "http://test.com")
        
        #expect(service != nil)
    }
    
    @Test func testLoginServiceWithDefaultURL() {
        let service = LoginModule.createLoginService()
        
        #expect(service != nil)
    }
    
    // MARK: - Complete Login Flow Tests
    
    @Test func testCompleteLoginFlow() async {
        let mockService = SimpleMockLoginService(shouldSucceed: true)
        let viewModel = LoginViewModel(loginService: mockService)
        
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        viewModel.login()
        
        // Wait for completion
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        #expect(viewModel.isLoggedIn == true)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func testCompleteLoginFlowWithError() async {
        let mockService = SimpleMockLoginService(shouldSucceed: false, mockError: .invalidCredentials)
        let viewModel = LoginViewModel(loginService: mockService)
        
        viewModel.email = "test@example.com"
        viewModel.password = "wrongpassword"
        
        viewModel.login()
        
        // Wait for completion
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        #expect(viewModel.isLoggedIn == false)
        #expect(viewModel.isLoading == false)
    }
    
    @Test func testCompleteLogoutFlow() async {
        let mockService = SimpleMockLoginService(shouldSucceed: true)
        let viewModel = LoginViewModel(loginService: mockService)
        
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        // Login first
        viewModel.login()
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        #expect(viewModel.isLoggedIn == true)
        
        // Logout
        viewModel.logout()
        
        #expect(viewModel.isLoggedIn == false)
        #expect(viewModel.email == "")
        #expect(viewModel.password == "")
    }
    
    // MARK: - Form Validation Integration Tests
    
    @Test func testFormValidationIntegration() {
        let viewModel = LoginModule.createLoginViewModel()
        
        // Initially invalid
        #expect(viewModel.isFormValid == false)
        
        // Add email only - still invalid
        viewModel.email = "test@example.com"
        #expect(viewModel.isFormValid == false)
        
        // Add password - now valid
        viewModel.password = "password123"
        #expect(viewModel.isFormValid == true)
        
        // Clear email - invalid again
        viewModel.email = ""
        #expect(viewModel.isFormValid == false)
    }
    
    // MARK: - Error Handling Integration Tests
    
    @Test func testErrorHandlingIntegration() async {
        let mockService = SimpleMockLoginService(shouldSucceed: false, mockError: .networkError("Server unavailable"))
        let viewModel = LoginViewModel(loginService: mockService)
        
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        viewModel.login()
        
        // Wait for completion
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Clear error
        viewModel.clearError()
        #expect(viewModel.errorMessage == nil)
    }
    
    // MARK: - Mock Service Tests
    
    @Test func testMockServiceSuccess() async throws {
        let mockService = SimpleMockLoginService(shouldSucceed: true)
        
        let response = try await mockService.login(user: "testuser", password: "testpass")
        
        #expect(response.accessToken.contains("testuser") == true)
    }
    
    @Test func testMockServiceFailure() async {
        let mockService = SimpleMockLoginService(shouldSucceed: false, mockError: .invalidCredentials)
        
        do {
            _ = try await mockService.login(user: "testuser", password: "testpass")
            #expect(Bool(false), "Should have thrown an error")
        } catch {
            #expect(error is LoginError)
        }
    }
    
    @Test func testMockServiceWithCustomResponse() async throws {
        let customResponse = LoginResponse(accessToken: "custom_token_123")
        let mockService = SimpleMockLoginService(shouldSucceed: true, mockResponse: customResponse)
        
        let response = try await mockService.login(user: "testuser", password: "testpass")
        
        #expect(response.accessToken == "custom_token_123")
    }
}
