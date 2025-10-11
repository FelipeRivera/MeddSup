//
//  LoginModule.swift
//  LoginModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

// MARK: - Public API
@available(iOS 15.0, macOS 10.15, *)
public struct LoginModule {
    public static func createLoginService(baseURL: String = "http://localhost:8080") -> LoginService {
        return LoginService(baseURL: baseURL)
    }
    
    @MainActor
    public static func createLoginViewModel(baseURL: String = "http://localhost:8080") -> LoginViewModel {
        let loginService = LoginService(baseURL: baseURL)
        return LoginViewModel(loginService: loginService)
    }
}
