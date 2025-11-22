//
//  MockVisitService.swift
//  VisitLogModuleTests
//
//  Created by GPT-5.1 Codex on 15/11/25.
//

import Foundation
@testable import VisitLogModule

final class MockVisitService: @unchecked Sendable, VisitServiceProtocol {
    var shouldSucceed: Bool = true
    var mockVisits: [VisitPayload] = []
    var mockError: Error?
    var submitVisitCallCount: Int = 0
    var fetchRecentVisitsCallCount: Int = 0
    var lastSubmittedPayload: VisitPayload?
    var lastFetchLimit: Int?
    
    init(shouldSucceed: Bool = true, mockVisits: [VisitPayload] = [], mockError: Error? = nil) {
        self.shouldSucceed = shouldSucceed
        self.mockVisits = mockVisits
        self.mockError = mockError
    }
    
    func fetchRecentVisits(limit: Int) async throws -> [VisitPayload] {
        fetchRecentVisitsCallCount += 1
        lastFetchLimit = limit
        
        if shouldSucceed {
            return mockVisits
        } else {
            throw mockError ?? VisitServiceError.server(message: "Test error")
        }
    }
    
    func submitVisit(_ payload: VisitPayload) async throws {
        submitVisitCallCount += 1
        lastSubmittedPayload = payload
        
        if shouldSucceed {
            return
        } else {
            throw mockError ?? VisitServiceError.server(message: "Test error")
        }
    }
}

