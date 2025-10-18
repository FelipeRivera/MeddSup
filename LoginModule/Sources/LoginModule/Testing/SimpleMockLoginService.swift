//
//  SimpleMockLoginService.swift
//  LoginModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

#if DEBUG
public class SimpleMockLoginService: LoginService, @unchecked Sendable {
    public var shouldSucceed: Bool = true
    public var mockResponse: LoginResponse?
    public var mockError: LoginError?
    
    public init(shouldSucceed: Bool = true, mockResponse: LoginResponse? = nil, mockError: LoginError? = nil) {
        self.shouldSucceed = shouldSucceed
        self.mockResponse = mockResponse
        self.mockError = mockError
        super.init(baseURL: "http://test.com")
    }
    
    public override func login(user: String, password: String) async throws -> LoginResponse {
        if shouldSucceed {
            if let response = mockResponse {
                return response
            } else {
                // Default mock includes role and expiry to match new server response
                return LoginResponse(accessToken: "mock_token_\(user)", expiresIn: 3600, role: "security_admin", tokenType: "Bearer")
            }
        } else {
            throw mockError ?? LoginError.invalidCredentials
        }
    }
}
#endif
