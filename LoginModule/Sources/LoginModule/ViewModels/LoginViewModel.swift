//
//  LoginViewModel.swift
//  LoginModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation
import SwiftUI

@MainActor
public final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published public var isLoggedIn: Bool = false
    
    private let loginService: LoginService
    private var loginTask: Task<Void, Never>?
    
    public init(loginService: LoginService) {
        self.loginService = loginService
    }
    
    public func login() {
        loginTask?.cancel()
        
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = .localized("error.validation.empty.fields")
            return
        }
        
        loginTask = Task { @MainActor in
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await loginService.login(user: email, password: password)
                
                UserDefaults.standard.set(response.accessToken, forKey: "access_token")
                isLoggedIn = true
                
            } catch {
                if Task.isCancelled {
                    return
                }
                
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    public func logout() {
        loginTask?.cancel()
        
        UserDefaults.standard.removeObject(forKey: "access_token")
        isLoggedIn = false
        email = ""
        password = ""
    }
    
    public func clearError() {
        errorMessage = nil
    }
    
    public var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !isLoading
    }
    
    deinit {
        loginTask?.cancel()
    }
}
