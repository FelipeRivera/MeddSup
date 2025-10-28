//
//  OrderStatusModels.swift
//  OrderStatusModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

// MARK: - Order Status Request
public struct OrderStatusRequest: Sendable, Codable {
    public let accessToken: String
    public let role: String
    
    public init(accessToken: String, role: String) {
        self.accessToken = accessToken
        self.role = role
    }
}

// MARK: - Order Status Response
public struct OrderStatus: Sendable, Codable, Identifiable {
    public let orderId: String
    public let statusId: String
    public let createdAt: String
    public let items: [OrderItem]
    public let monto: Double
    
    // Use orderId as the id for Identifiable
    public var id: String { orderId }
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_number"
        case statusId = "status"
        case createdAt = "created_at"
        case items
        case monto
    }
    
    public init(orderId: String, statusId: String, createdAt: String, items: [OrderItem], monto: Double) {
        self.orderId = orderId
        self.statusId = statusId
        self.createdAt = createdAt
        self.items = items
        self.monto = monto
    }
}

public struct OrderItem: Sendable, Codable {
    public let id: String
    public let name: String
    public let quantity: Int
    public let price: Double
    
    public init(id: String, name: String, quantity: Int, price: Double) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.price = price
    }
}

// MARK: - Order Status Enum
public enum OrderStatusType: String, CaseIterable {
    case enPreparacion = "En preparacion"
    case transito = "transito"
    case entregado = "entregado"
    case pendiente = "pendiente"
    
    public var localizedStatus: String {
        switch self {
        case .enPreparacion:
            return OrderStatusLocalizationHelper.shared.localizedString(for: "status.en_preparacion")
        case .transito:
            return OrderStatusLocalizationHelper.shared.localizedString(for: "status.transito")
        case .entregado:
            return OrderStatusLocalizationHelper.shared.localizedString(for: "status.entregado")
        case .pendiente:
            return OrderStatusLocalizationHelper.shared.localizedString(for: "status.pendiente")
        }
    }
    
    public var statusColor: String {
        switch self {
        case .enPreparacion:
            return "orange"
        case .transito:
            return "green"
        case .entregado:
            return "mutedGreen"
        case .pendiente:
            return "gray"
        }
    }
    
    public static func from(statusId: String) -> OrderStatusType? {
        return OrderStatusType.allCases.first { $0.rawValue == statusId }
    }
}

// MARK: - Order Status Error
public enum OrderStatusError: Sendable, Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
    case unauthorized
    case serverError(Int)
    case invalidToken
    case invalidRole
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return OrderStatusLocalizationHelper.shared.localizedString(for: "error.invalid_url")
        case .noData:
            return OrderStatusLocalizationHelper.shared.localizedString(for: "error.no_data")
        case .decodingError:
            return OrderStatusLocalizationHelper.shared.localizedString(for: "error.decoding")
        case .networkError(let message):
            return OrderStatusLocalizationHelper.shared.localizedString(for: "error.network", arguments: message)
        case .unauthorized:
            return OrderStatusLocalizationHelper.shared.localizedString(for: "error.unauthorized")
        case .serverError(let code):
            return OrderStatusLocalizationHelper.shared.localizedString(for: "error.server", arguments: "\(code)")
        case .invalidToken:
            return OrderStatusLocalizationHelper.shared.localizedString(for: "error.invalid_token")
        case .invalidRole:
            return OrderStatusLocalizationHelper.shared.localizedString(for: "error.invalid_role")
        }
    }
}
