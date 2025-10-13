//
//  ViewClientsModule.swift
//  ViewClientsModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI

@available(iOS 16.0, *)
public struct ViewClientsModule {
    
    @MainActor public static func createViewClientsView(baseURL: String, token: String, role: String) -> some View {
        ViewClientsView(baseURL: baseURL, token: token, role: role)
    }
    
    @MainActor public static func createViewClientsViewWithMock(baseURL: String, token: String, role: String) -> some View {
        ViewClientsView(baseURL: baseURL, token: token, role: role)
    }
    
    @MainActor public static func createViewClientsViewModel() -> ViewClientsViewModel {
        ViewClientsViewModel()
    }
    
    @MainActor public static func createViewClientsViewModel(with service: ClientServiceProtocol) -> ViewClientsViewModel {
        ViewClientsViewModel(clientService: service)
    }
}
