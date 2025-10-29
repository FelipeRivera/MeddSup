//
//  ProductModels.swift
//  CreateOrderModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

// MARK: - Product Model
public struct Product: Identifiable, Codable, Hashable, Sendable {
    public let id = UUID()
    public let name: String
    public let nombre: String
    public let code: String
    public let codigo: String
    public let reference: String
    public let referencia: String
    public let description: String
    public let descripcion: String
    public let unitPrice: Double
    public let precioVenta: Double
    public let status: String
    public let isDeleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, nombre
        case code, codigo
        case reference, referencia
        case description, descripcion
        case unitPrice = "unit_price"
        case precioVenta = "precio_venta"
        case status
        case isDeleted = "is_deleted"
    }
    
    public init(
        name: String,
        nombre: String,
        code: String,
        codigo: String,
        reference: String,
        referencia: String,
        description: String,
        descripcion: String,
        unitPrice: Double,
        precioVenta: Double,
        status: String,
        isDeleted: Bool
    ) {
        self.name = name
        self.nombre = nombre
        self.code = code
        self.codigo = codigo
        self.reference = reference
        self.referencia = referencia
        self.description = description
        self.descripcion = descripcion
        self.unitPrice = unitPrice
        self.precioVenta = precioVenta
        self.status = status
        self.isDeleted = isDeleted
    }
}

// MARK: - Order Item Model
public struct OrderItem: Sendable, Identifiable, Codable {
    public var id = UUID()
    public let product: Product
    public var quantity: Int
    
    public init(product: Product, quantity: Int = 1) {
        self.product = product
        self.quantity = quantity
    }
    
    public var totalPrice: Double {
        return product.unitPrice * Double(quantity)
    }
}

// MARK: - Create Order Request Model
public struct CreateOrderRequest: Sendable, Codable {
    public let orderNumber: String
    public let status: String
    public let items: [OrderItem]?
    
    enum CodingKeys: String, CodingKey {
        case orderNumber = "order_number"
        case status
        case items
    }
    
    public init(orderNumber: String, status: String, items: [OrderItem]? = nil) {
        self.orderNumber = orderNumber
        self.status = status
        self.items = items
    }
}

// MARK: - Mock Products Data
public extension Product {
    static let mockProducts: [Product] = [
        Product(
            name: "Simvastatina 20mg",
            nombre: "Simvastatina 20mg",
            code: "MED-007",
            codigo: "MED-007",
            reference: "REF-SIM-20",
            referencia: "REF-SIM-20",
            description: "Hipolipemiante",
            descripcion: "Hipolipemiante",
            unitPrice: 1.90,
            precioVenta: 1.90,
            status: "active",
            isDeleted: false
        ),
        Product(
            name: "Producto 1",
            nombre: "Producto 1",
            code: "PROD-001",
            codigo: "PROD-001",
            reference: "REF-PROD-1",
            referencia: "REF-PROD-1",
            description: "Medicamento genérico",
            descripcion: "Medicamento genérico",
            unitPrice: 10.00,
            precioVenta: 10.00,
            status: "active",
            isDeleted: false
        ),
        Product(
            name: "Producto 2",
            nombre: "Producto 2",
            code: "PROD-002",
            codigo: "PROD-002",
            reference: "REF-PROD-2",
            referencia: "REF-PROD-2",
            description: "Medicamento genérico",
            descripcion: "Medicamento genérico",
            unitPrice: 15.00,
            precioVenta: 15.00,
            status: "active",
            isDeleted: false
        ),
        Product(
            name: "Atorvastatina 40mg",
            nombre: "Atorvastatina 40mg",
            code: "MED-008",
            codigo: "MED-008",
            reference: "REF-ATO-40",
            referencia: "REF-ATO-40",
            description: "Hipolipemiante",
            descripcion: "Hipolipemiante",
            unitPrice: 2.50,
            precioVenta: 2.50,
            status: "active",
            isDeleted: false
        ),
        Product(
            name: "Paracetamol 500mg",
            nombre: "Paracetamol 500mg",
            code: "MED-009",
            codigo: "MED-009",
            reference: "REF-PAR-500",
            referencia: "REF-PAR-500",
            description: "Analgésico y antipirético",
            descripcion: "Analgésico y antipirético",
            unitPrice: 0.50,
            precioVenta: 0.50,
            status: "active",
            isDeleted: false
        ),
        Product(
            name: "Ibuprofeno 400mg",
            nombre: "Ibuprofeno 400mg",
            code: "MED-010",
            codigo: "MED-010",
            reference: "REF-IBU-400",
            referencia: "REF-IBU-400",
            description: "Antiinflamatorio no esteroideo",
            descripcion: "Antiinflamatorio no esteroideo",
            unitPrice: 0.75,
            precioVenta: 0.75,
            status: "active",
            isDeleted: false
        )
    ]
}

