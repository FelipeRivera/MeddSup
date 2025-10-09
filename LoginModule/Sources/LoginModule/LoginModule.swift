//
//  LoginModule.swift
//  LoginModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

// MARK: - Public API
public struct LoginModule {
    public static func createLoginService(baseURL: String = "http://localhost:8080") -> LoginService {
        return LoginService(baseURL: baseURL)
    }
    
    @MainActor
    public static func createLoginViewModel(loginService: LoginService? = nil) -> LoginViewModel {
        if let service = loginService {
            return LoginViewModel(loginService: service)
        } else {
            return LoginViewModel()
        }
    }
}
