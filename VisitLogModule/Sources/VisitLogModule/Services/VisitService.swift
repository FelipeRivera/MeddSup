//
//  VisitService.swift
//  VisitLogModule
//
//  Created by GPT-5.1 Codex on 15/11/25.
//

import Foundation

/// Protocol describing the operations required by the Visit Route feature.
public protocol VisitServiceProtocol: Sendable {
    func fetchRecentVisits(limit: Int) async throws -> [VisitPayload]
    func submitVisit(_ payload: VisitPayload) async throws
}

/// Concrete implementation that communicates with the backend REST service.
public final class VisitService: @unchecked Sendable, VisitServiceProtocol {
    private let baseURL: URL
    private let urlSession: URLSession
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    public init(baseURL: String, urlSession: URLSession = .shared) {
        self.baseURL = URL(string: baseURL) ?? URL(string: "http://52.55.197.150/visits")!
        self.urlSession = urlSession
        
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.outputFormatting = .withoutEscapingSlashes
        
        self.jsonDecoder = JSONDecoder()
    }
    
    public func fetchRecentVisits(limit: Int) async throws -> [VisitPayload] {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw VisitServiceError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        
        guard let url = components.url else {
            throw VisitServiceError.invalidURL
        }
        
        let (data, response) = try await urlSession.data(from: url)
        try validate(response: response, data: data)
        
        return try jsonDecoder.decode([VisitPayload].self, from: data)
    }
    
    public func submitVisit(_ payload: VisitPayload) async throws {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(payload)
        
        let (data, response) = try await urlSession.data(for: request)
        try validate(response: response, data: data)
    }
    
    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VisitServiceError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return
        default:
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw VisitServiceError.server(message: message)
        }
    }
}

public enum VisitServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case server(message: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return VisitLogLocalizationHelper.shared.localizedString(for: "visitroute.error.invalid.url")
        case .invalidResponse:
            return VisitLogLocalizationHelper.shared.localizedString(for: "visitroute.error.invalid.response")
        case .server(let message):
            return message
        }
    }
}


