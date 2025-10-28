//
//  ViewModelTests.swift
//  LoginModuleTests
//
//  Created by Felipe Rivera on 3/09/25.
//

import Testing
@testable import LoginModule

@MainActor
struct ViewModelTests {
    
    // MARK: - Initialization Tests
    
    @Test func testInitialState() {
        let mockService = SimpleMockLoginService()
        let viewModel = LoginViewModel(loginService: mockService)
        
        #expect(viewModel.email == "")
        #expect(viewModel.password == "")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    // MARK: - Form Validation Tests
    
    @Test func testFormValidationWithEmptyFields() {
        let mockService = SimpleMockLoginService()
        let viewModel = LoginViewModel(loginService: mockService)
        
        viewModel.email = ""
        viewModel.password = ""
        
        #expect(viewModel.isFormValid == false)
    }
    
    @Test func testFormValidationWithBothFields() {
        let mockService = SimpleMockLoginService()
        let viewModel = LoginViewModel(loginService: mockService)
        
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        #expect(viewModel.isFormValid == true)
    }
    
    @Test func testFormValidationWhileLoading() {
        let mockService = SimpleMockLoginService()
        let viewModel = LoginViewModel(loginService: mockService)
        
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.isLoading = true
        
        #expect(viewModel.isFormValid == false)
    }
    
    // MARK: - Login Tests
    
    @Test func testSuccessfulLogin() async {
        let mockService = SimpleMockLoginService(shouldSucceed: true)
        let viewModel = LoginViewModel(loginService: mockService)
        
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        viewModel.login()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(viewModel.isLoggedIn == true)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func testLoginWithInvalidCredentials() async {
        let mockService = SimpleMockLoginService(shouldSucceed: false, mockError: .invalidCredentials)
        let viewModel = LoginViewModel(loginService: mockService)
        
        viewModel.email = "test@example.com"
        viewModel.password = "wrongpassword"
        
        viewModel.login()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        #expect(viewModel.isLoading == false)
    }
    
    // MARK: - Logout Tests
    
    @Test func testLogout() {
        let mockService = SimpleMockLoginService()
        let viewModel = LoginViewModel(loginService: mockService)
        
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.isLoggedIn = true
        
        viewModel.logout()
        
        #expect(viewModel.isLoggedIn == false)
        #expect(viewModel.email == "")
        #expect(viewModel.password == "")
    }
    
    // MARK: - Error Clearing Tests
    
    @Test func testClearError() {
        let mockService = SimpleMockLoginService()
        let viewModel = LoginViewModel(loginService: mockService)
        
        viewModel.errorMessage = "Test error"
        
        viewModel.clearError()
        
        #expect(viewModel.errorMessage == nil)
    }
}
