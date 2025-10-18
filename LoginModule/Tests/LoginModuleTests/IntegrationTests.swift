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
}
