//
//  LoginViewModel.swift
//  LoginModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation
import SwiftUI

@available(iOS 15.0, macOS 10.15, *)
@MainActor
public final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorKey: String?
    @Published var errorMessage: String?
    @Published public var isLoggedIn: Bool = false
    
    private let loginService: LoginService
    private var loginTask: Task<Void, Never>?
    
    // UserDefaults keys
    private let tokenKey = "access_token"
    private let roleKey = "user_role"
    private let tokenExpiryKey = "access_token_expires_at"
    
    public init(loginService: LoginService) {
        self.loginService = loginService
        
        if UserDefaults.standard.string(forKey: tokenKey) != nil {
            if let expiry = UserDefaults.standard.object(forKey: tokenExpiryKey) as? TimeInterval {
                let expiryDate = Date(timeIntervalSince1970: expiry)
                if expiryDate > Date() {
                    // Token still valid
                    isLoggedIn = true
                } else {
                    // Token expired - clear
                    UserDefaults.standard.removeObject(forKey: tokenKey)
                    UserDefaults.standard.removeObject(forKey: roleKey)
                    UserDefaults.standard.removeObject(forKey: tokenExpiryKey)
                    isLoggedIn = false
                }
            } else {
                isLoggedIn = true
            }
        } else {
            isLoggedIn = false
        }
    }
    
    public func login() {
        loginTask?.cancel()
        
        // Trim email
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validation
        guard !trimmedEmail.isEmpty && !password.isEmpty else {
            errorKey = "error.validation.empty.fields"
            errorMessage = nil
            return
        }
        
        guard isValidEmail(trimmedEmail) else {
            errorKey = "error.validation.invalid.email"
            errorMessage = nil
            return
        }
        
        guard password.count >= 8 else {
            errorKey = "error.validation.password.too.short"
            errorMessage = nil
            return
        }
        
        errorKey = nil
        errorMessage = nil
        
        loginTask = Task { @MainActor in
            isLoading = true
            
            do {
                let response = try await loginService.login(user: trimmedEmail, password: password)
                
                // Persist token
                UserDefaults.standard.set(response.accessToken, forKey: tokenKey)
                
                // Persist role if provided
                if let role = response.role {
                    UserDefaults.standard.set(role, forKey: roleKey)
                }
                
                // Persist expiry if provided
                if let expiresIn = response.expiresIn {
                    let expiryTimestamp = Date().addingTimeInterval(TimeInterval(expiresIn)).timeIntervalSince1970
                    UserDefaults.standard.set(expiryTimestamp, forKey: tokenExpiryKey)
                } else {
                    UserDefaults.standard.removeObject(forKey: tokenExpiryKey)
                }
                
                isLoggedIn = true
                
            } catch {
                if Task.isCancelled {
                    return
                }
                
                errorMessage = error.localizedDescription
                errorKey = nil
            }
            
            isLoading = false
        }
    }
    
    public func logout() {
        loginTask?.cancel()
        
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: roleKey)
        UserDefaults.standard.removeObject(forKey: tokenExpiryKey)
        isLoggedIn = false
        email = ""
        password = ""
    }
    
    public func clearError() {
        errorKey = nil
        errorMessage = nil
    }
    
    public var isFormValid: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedEmail.isEmpty && !password.isEmpty && !isLoading
    }
    
    deinit {
        loginTask?.cancel()
    }
    
    // MARK: - Validation helpers
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", pattern)
        return predicate.evaluate(with: email)
    }
}
