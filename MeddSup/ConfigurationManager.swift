//
//  ConfigurationManager.swift
//  MeddSup
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

public class ConfigurationManager: ObservableObject {
    public static let shared = ConfigurationManager()
    
    // MARK: - API Endpoints
    public struct APIEndpoints {
        public let authBaseURL: String
        public let portalBaseURL: String
        public let ordersAPIURL: String
        public let createOrderAPIURL: String
        
        public init(
            authBaseURL: String = "http://52.55.197.150/auth",
            portalBaseURL: String = "http://portal-web-alb-701001447.us-east-1.elb.amazonaws.com",
            ordersAPIURL: String = "http://52.55.197.150/orders/api/orders",
            createOrderAPIURL: String = "http://52.55.197.150/api/orders"
        ) {
            self.authBaseURL = authBaseURL
            self.portalBaseURL = portalBaseURL
            self.ordersAPIURL = ordersAPIURL
            self.createOrderAPIURL = createOrderAPIURL
        }
    }
    
    // MARK: - User Session
    public struct UserSession {
        public let token: String
        public let role: String
        
        public init(token: String, role: String) {
            self.token = token
            self.role = role
        }
    }
    
    @Published public var endpoints: APIEndpoints
    @Published public var userSession: UserSession?
    
    private init() {
        self.endpoints = APIEndpoints()
    }
    
    public func updateUserSession(token: String, role: String) {
        self.userSession = UserSession(token: token, role: role)
    }
    
    public func clearUserSession() {
        self.userSession = nil
    }
}
