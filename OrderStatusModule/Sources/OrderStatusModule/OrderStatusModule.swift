//
//  OrderStatusModule.swift
//  OrderStatusModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI

public struct OrderStatusModule {
    @MainActor
    public static func createOrderStatusView(baseURL: String, token: String, role: String) -> some View {
        OrderStatusView(baseURL: baseURL, token: token, role: role)
    }
    
    @MainActor
    public static func createOrderStatusViewModel(baseURL: String, token: String, role: String) -> OrderStatusViewModel {
        OrderStatusViewModel(baseURL: baseURL, token: token, role: role)
    }
    
    // Helper method to get token from UserDefaults
    public static func getStoredToken() -> String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    // Helper method to get role from UserDefaults
    public static func getStoredRole() -> String? {
        return UserDefaults.standard.string(forKey: "user_role")
    }
}