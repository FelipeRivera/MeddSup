//
//  customerRegistrationModule.swift
//  customerRegistrationModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI

@MainActor
public enum CustomerRegistrationModule {
    // MARK: - Factory Methods
    public static func createCustomerRegistrationView(
        baseURL: String,
        token: String
    ) -> some View {
        let service = CustomerRegistrationService(baseURL: baseURL)
        let viewModel = CustomerRegistrationViewModel(service: service, token: token)
        return CustomerRegistrationView(viewModel: viewModel)
    }
    
    public static func createCustomerRegistrationViewModel(
        baseURL: String,
        token: String
    ) -> CustomerRegistrationViewModel {
        let service = CustomerRegistrationService(baseURL: baseURL)
        return CustomerRegistrationViewModel(service: service, token: token)
    }
    
    // MARK: - Helper Methods
    public static func getStoredToken() -> String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
}
