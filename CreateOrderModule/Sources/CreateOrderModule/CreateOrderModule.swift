//
//  CreateOrderModule.swift
//  CreateOrderModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI

@MainActor
public enum CreateOrderModule {
    // MARK: - Factory Methods
    public static func createCreateOrderView(
        baseURL: String,
        token: String
    ) -> some View {
        let service = CreateOrderService(baseURL: baseURL)
        let viewModel = CreateOrderViewModel(service: service, token: token)
        return CreateOrderView(viewModel: viewModel)
    }
    
    public static func createCreateOrderViewModel(
        baseURL: String,
        token: String
    ) -> CreateOrderViewModel {
        let service = CreateOrderService(baseURL: baseURL)
        return CreateOrderViewModel(service: service, token: token)
    }
}
