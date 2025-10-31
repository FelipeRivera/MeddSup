//
//  CreateOrderService.swift
//  CreateOrderModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

public protocol CreateOrderServiceProtocol: Sendable {
    func createOrder(request: CreateOrderRequest, token: String) async throws
}

public final class CreateOrderService: @unchecked Sendable, CreateOrderServiceProtocol {
    private let baseURL: String
    private let urlSession: URLSession
    
    public init(baseURL: String, urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }
    
    public func createOrder(request: CreateOrderRequest, token: String) async throws {
        guard let url = URL(string: "\(baseURL)") else {
            throw CreateOrderError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Create a custom JSON structure for the request
        var jsonBody: [String: Any] = [
            "order_number": request.orderNumber,
            "status": request.status
        ]
        
        // Add products array if items exist
        if let items = request.items {
            let productsArray = items.map { item -> [String: Any] in
                [
                    "name": item.product.name,
                    "nombre": item.product.nombre,
                    "code": item.product.code,
                    "codigo": item.product.codigo,
                    "reference": item.product.reference,
                    "referencia": item.product.referencia,
                    "description": item.product.description,
                    "descripcion": item.product.descripcion,
                    "unit_price": item.product.unitPrice,
                    "precio_venta": item.product.precioVenta,
                    "status": item.product.status,
                    "is_deleted": item.product.isDeleted,
                    "quantity": item.quantity
                ]
            }
            jsonBody["products"] = productsArray
        }
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
        
        let (_, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CreateOrderError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw CreateOrderError.serverError(httpResponse.statusCode)
        }
    }
}

// MARK: - Errors
public enum CreateOrderError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case networkError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

