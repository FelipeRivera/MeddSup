//
//  CreateOrderViewModel.swift
//  CreateOrderModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation
import SwiftUI

@MainActor
public final class CreateOrderViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var products: [Product] = Product.mockProducts
    @Published public var orderItems: [OrderItem] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var showSuccessAlert: Bool = false
    
    // MARK: - Private Properties
    private let service: CreateOrderServiceProtocol
    private let token: String
    
    // MARK: - Computed Properties
    public var totalPrice: Double {
        orderItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    // MARK: - Initialization
    public init(service: CreateOrderServiceProtocol, token: String) {
        self.service = service
        self.token = token
    }
    
    // MARK: - Public Methods
    public func addProduct(_ product: Product, quantity: Int) {
        if quantity <= 0 {
            // Remove product if quantity is 0 or less
            orderItems.removeAll { $0.product.id == product.id }
        } else {
            // Update or add product
            if let index = orderItems.firstIndex(where: { $0.product.id == product.id }) {
                orderItems[index].quantity = quantity
            } else {
                orderItems.append(OrderItem(product: product, quantity: quantity))
            }
        }
    }
    
    public func getQuantity(for product: Product) -> Int {
        return orderItems.first(where: { $0.product.id == product.id })?.quantity ?? 0
    }
    
    public func clearOrder() {
        orderItems.removeAll()
    }
    
    public func modifyOrder() {
        // Clear the order items
        clearOrder()
    }
    
    public func confirmOrder() async {
        guard !orderItems.isEmpty else {
            errorMessage = CreateOrderLocalizationHelper.shared.localizedString(for: "createorder.enter.products")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Generate order number
            let orderNumber = "ORD-\(Int.random(in: 1000...9999))"
            
            // Create order request
            let request = CreateOrderRequest(
                orderNumber: orderNumber,
                status: "En preparacion",
                items: orderItems
            )
            
            try await service.createOrder(request: request, token: token)
            
            // Show success and clear order
            showSuccessAlert = true
            clearOrder()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

