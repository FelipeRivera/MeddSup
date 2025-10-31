//
//  CreateOrderModuleTests.swift
//  CreateOrderModuleTests
//
//  Created by Felipe Rivera on 3/09/25.
//

import Testing
import Foundation
@testable import CreateOrderModule

@MainActor
struct CreateOrderViewModelTests {
    
    // MARK: - Test Data
    private func createMockService() -> MockCreateOrderService {
        MockCreateOrderService()
    }
    
    private func createMockProduct() -> Product {
        Product(
            name: "Test Product",
            nombre: "Producto de Prueba",
            code: "TEST-001",
            codigo: "TEST-001",
            reference: "REF-TEST-001",
            referencia: "REF-TEST-001",
            description: "Test Description",
            descripcion: "Descripción de Prueba",
            unitPrice: 10.0,
            precioVenta: 10.0,
            status: "active",
            isDeleted: false
        )
    }
    
    // MARK: - Add Product Tests
    @Test("Add product with valid quantity")
    func testAddProductWithValidQuantity() {
        let service = createMockService()
        let viewModel = CreateOrderViewModel(service: service, token: "test_token")
        
        let product = createMockProduct()
        viewModel.addProduct(product, quantity: 2)
        
        #expect(viewModel.orderItems.count == 1)
        #expect(viewModel.getQuantity(for: product) == 2)
    }
    
    @Test("Add product with quantity zero removes product")
    func testAddProductWithQuantityZero() {
        let service = createMockService()
        let viewModel = CreateOrderViewModel(service: service, token: "test_token")
        
        let product = createMockProduct()
        viewModel.addProduct(product, quantity: 2)
        viewModel.addProduct(product, quantity: 0)
        
        #expect(viewModel.orderItems.isEmpty)
        #expect(viewModel.getQuantity(for: product) == 0)
    }
    
    @Test("Update existing product quantity")
    func testUpdateExistingProductQuantity() {
        let service = createMockService()
        let viewModel = CreateOrderViewModel(service: service, token: "test_token")
        
        let product = createMockProduct()
        viewModel.addProduct(product, quantity: 2)
        viewModel.addProduct(product, quantity: 5)
        
        #expect(viewModel.orderItems.count == 1)
        #expect(viewModel.getQuantity(for: product) == 5)
    }
    
    @Test("Add multiple different products")
    func testAddMultipleDifferentProducts() {
        let service = createMockService()
        let viewModel = CreateOrderViewModel(service: service, token: "test_token")
        
        let product1 = createMockProduct()
        let product2 = Product(
            name: "Test Product 2",
            nombre: "Producto de Prueba 2",
            code: "TEST-002",
            codigo: "TEST-002",
            reference: "REF-TEST-002",
            referencia: "REF-TEST-002",
            description: "Test Description 2",
            descripcion: "Descripción de Prueba 2",
            unitPrice: 15.0,
            precioVenta: 15.0,
            status: "active",
            isDeleted: false
        )
        
        viewModel.addProduct(product1, quantity: 3)
        viewModel.addProduct(product2, quantity: 2)
        
        #expect(viewModel.orderItems.count == 2)
        #expect(viewModel.getQuantity(for: product1) == 3)
        #expect(viewModel.getQuantity(for: product2) == 2)
    }
    
    // MARK: - Get Quantity Tests
    @Test("Get quantity for product not in order returns zero")
    func testGetQuantityForProductNotInOrder() {
        let service = createMockService()
        let viewModel = CreateOrderViewModel(service: service, token: "test_token")
        
        let product = createMockProduct()
        
        #expect(viewModel.getQuantity(for: product) == 0)
    }
    
    // MARK: - Total Price Tests
    @Test("Calculate total price correctly")
    func testCalculateTotalPrice() {
        let service = createMockService()
        let viewModel = CreateOrderViewModel(service: service, token: "test_token")
        
        let product1 = createMockProduct() // 10.0 per unit
        let product2 = Product(
            name: "Test Product 2",
            nombre: "Producto de Prueba 2",
            code: "TEST-002",
            codigo: "TEST-002",
            reference: "REF-TEST-002",
            referencia: "REF-TEST-002",
            description: "Test Description 2",
            descripcion: "Descripción de Prueba 2",
            unitPrice: 15.0,
            precioVenta: 15.0,
            status: "active",
            isDeleted: false
        ) // 15.0 per unit
        
        viewModel.addProduct(product1, quantity: 2) // 20.0
        viewModel.addProduct(product2, quantity: 3) // 45.0
        
        #expect(viewModel.totalPrice == 65.0)
    }
    
    @Test("Total price is zero when order is empty")
    func testTotalPriceZeroWhenEmpty() {
        let service = createMockService()
        let viewModel = CreateOrderViewModel(service: service, token: "test_token")
        
        #expect(viewModel.totalPrice == 0.0)
    }
    
    // MARK: - Clear Order Tests
    @Test("Clear order removes all products")
    func testClearOrderRemovesAllProducts() {
        let service = createMockService()
        let viewModel = CreateOrderViewModel(service: service, token: "test_token")
        
        let product1 = createMockProduct()
        let product2 = createMockProduct()
        
        viewModel.addProduct(product1, quantity: 2)
        viewModel.addProduct(product2, quantity: 3)
        
        viewModel.clearOrder()
        
        #expect(viewModel.orderItems.isEmpty)
        #expect(viewModel.totalPrice == 0.0)
    }
    
    // MARK: - Modify Order Tests
    @Test("Modify order clears order")
    func testModifyOrderClearsOrder() {
        let service = createMockService()
        let viewModel = CreateOrderViewModel(service: service, token: "test_token")
        
        let product = createMockProduct()
        viewModel.addProduct(product, quantity: 2)
        
        viewModel.modifyOrder()
        
        #expect(viewModel.orderItems.isEmpty)
    }
    
    // MARK: - Confirm Order Tests
    @Test("Confirm order with empty cart sets error message")
    func testConfirmOrderWithEmptyCart() async {
        let service = createMockService()
        let viewModel = CreateOrderViewModel(service: service, token: "test_token")
        
        await viewModel.confirmOrder()
        
        #expect(viewModel.errorMessage != nil)
        #expect(!viewModel.showSuccessAlert)
        #expect(viewModel.orderItems.isEmpty)
    }
    
    @Test("Confirm order successfully calls service")
    func testConfirmOrderSuccessfully() async throws {
        let service = createMockService()
        service.shouldSucceed = true
        let viewModel = CreateOrderViewModel(service: service, token: "test_token")
        
        let product = createMockProduct()
        viewModel.addProduct(product, quantity: 2)
        
        await viewModel.confirmOrder()
        
        #expect(service.createOrderCalled)
        #expect(service.lastRequest != nil)
        #expect(service.lastToken == "test_token")
        #expect(viewModel.showSuccessAlert)
        #expect(viewModel.orderItems.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Confirm order with service error shows error message")
    func testConfirmOrderWithServiceError() async {
        let service = createMockService()
        service.shouldSucceed = false
        let viewModel = CreateOrderViewModel(service: service, token: "test_token")
        
        let product = createMockProduct()
        viewModel.addProduct(product, quantity: 2)
        
        await viewModel.confirmOrder()
        
        #expect(service.createOrderCalled)
        #expect(viewModel.errorMessage != nil)
        #expect(!viewModel.showSuccessAlert)
        #expect(!viewModel.orderItems.isEmpty) // Order not cleared on error
    }
    
    @Test("Confirm order sets loading state correctly")
    func testConfirmOrderLoadingState() async {
        let service = createMockService()
        let viewModel = CreateOrderViewModel(service: service, token: "test_token")
        
        let product = createMockProduct()
        viewModel.addProduct(product, quantity: 2)
        
        // Note: We can't easily test the loading state in between because it's async
        // but we can verify it starts false and ends false
        #expect(!viewModel.isLoading)
        
        await viewModel.confirmOrder()
        
        #expect(!viewModel.isLoading)
    }
}
