//
//  ModuleFactory.swift
//  MeddSup
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI
import LoginModule
import ViewClientsModule
import OrderStatusModule
import CreateOrderModule
import customerRegistrationModule
import VisitLogModule

@MainActor
public class ModuleFactory: ObservableObject {
    private let configuration: ConfigurationManager
    
    public init(configuration: ConfigurationManager = .shared) {
        self.configuration = configuration
    }
    
    // MARK: - Module Creation
    public func createLoginModule() -> LoginViewModel {
        return LoginModule.createLoginViewModel(
            baseURL: configuration.endpoints.authBaseURL
        )
    }
    
    public func createViewClientsModule() -> some View {
        guard let session = configuration.userSession else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            ViewClientsModule.createViewClientsView(
                baseURL: configuration.endpoints.portalBaseURL,
                token: session.token,
                role: session.role
            )
        )
    }
    
    public func createOrderStatusModule() -> some View {
        guard let session = configuration.userSession else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            OrderStatusModule.createOrderStatusView(
                baseURL: configuration.endpoints.ordersAPIURL,
                token: session.token,
                role: session.role
            )
        )
    }
    
    public func createCreateOrderModule() -> some View {
        guard let token = CreateOrderModule.getStoredToken() else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            CreateOrderModule.createCreateOrderView(
                baseURL: configuration.endpoints.createOrderAPIURL,
                token: token
            )
        )
    }
    
    public func createCustomerRegistrationModule() -> some View {
        guard let token = CustomerRegistrationModule.getStoredToken() else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            CustomerRegistrationModule.createCustomerRegistrationView(
                baseURL: configuration.endpoints.clientsAPIURL,
                token: token
            )
        )
    }
    
    public func createVisitLogModule(commercialId: Int = 7) -> some View {
        AnyView(
            VisitLogModule.createRoutePlanningView(
                baseURL: configuration.endpoints.visitsAPIURL,
                commercialId: commercialId
            )
        )
    }
}
