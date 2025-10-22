//
//  OrderStatusViewModel.swift
//  OrderStatusModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation
import SwiftUI

@MainActor
public class OrderStatusViewModel: ObservableObject {
    @Published public var orders: [OrderStatus] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var searchText = ""
    @Published public var filteredOrders: [OrderStatus] = []
    
    private let service: OrderStatusServiceProtocol
    private let baseURL: String
    private let token: String
    private let role: String
    
    @MainActor
    public init(baseURL: String, token: String, role: String, service: OrderStatusServiceProtocol? = nil) {
        self.baseURL = baseURL
        self.token = token
        self.role = role
        self.service = service ?? OrderStatusService(baseURL: baseURL)
    }
    
    public func loadOrders() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = OrderStatusRequest(accessToken: token, role: role)
            let response = try await service.fetchOrderStatus(request: request)
            
            orders = response.orders
            filteredOrders = orders
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    public func searchOrders() {
        if searchText.isEmpty {
            filteredOrders = orders
        } else {
            filteredOrders = orders.filter { order in
                order.orderId.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    public func getStatusType(for order: OrderStatus) -> OrderStatusType? {
        return OrderStatusType.from(statusId: order.statusId)
    }
    
    public func getStatusColor(for statusType: OrderStatusType) -> Color {
        switch statusType.statusColor {
        case "orange":
            return Color.orange
        case "green":
            return Color.green
        case "mutedGreen":
            return Color.green.opacity(0.7)
        case "gray":
            return Color.gray
        default:
            return Color.gray
        }
    }
    
    public func refreshOrders() async {
        await loadOrders()
    }
}
