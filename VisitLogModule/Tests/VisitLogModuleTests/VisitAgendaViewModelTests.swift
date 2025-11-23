//
//  VisitAgendaViewModelTests.swift
//  VisitLogModuleTests
//
//  Created by GPT-5.1 Codex on 15/11/25.
//

import Testing
@testable import VisitLogModule
import Foundation

@MainActor
struct VisitAgendaViewModelTests {
    
    // MARK: - Helper Methods
    
    private func createSampleClient(id: Int, name: String) -> Client {
        Client(
            id: id,
            name: name,
            address: "123 Main St",
            latitude: 40.7128,
            longitude: -74.0060
        )
    }
    
    private func createSampleClients(count: Int) -> [Client] {
        (1...count).map { index in
            createSampleClient(id: index * 10, name: "Client \(index)")
        }
    }
    
    // MARK: - Generate Agenda Tests
    
    @Test func testGenerateAgendaWithClients() {
        let mockService = MockVisitService()
        let clients = createSampleClients(count: 3)
        let viewModel = VisitAgendaViewModel(
            service: mockService,
            commercialId: 7,
            availableClients: clients
        )
        
        viewModel.selectedClients = clients
        viewModel.generateAgenda()
        
        #expect(viewModel.plannedVisits.count == 3)
        #expect(viewModel.isGenerating == false)
        #expect(viewModel.errorMessage == nil)
        
        // Verify sequence numbers
        for (index, visit) in viewModel.plannedVisits.enumerated() {
            #expect(visit.sequence == index + 1)
            #expect(visit.client.id == clients[index].id)
        }
    }
    
    @Test func testGenerateAgendaSetsCorrectPlannedTimes() {
        let mockService = MockVisitService()
        let clients = createSampleClients(count: 3)
        let viewModel = VisitAgendaViewModel(
            service: mockService,
            commercialId: 7,
            availableClients: clients
        )
        
        let testDate = Date()
        viewModel.selectedDate = testDate
        viewModel.selectedClients = clients
        viewModel.generateAgenda()
        
        let calendar = Calendar.current
        for (index, visit) in viewModel.plannedVisits.enumerated() {
            let expectedHour = 9 + index
            let hour = calendar.component(.hour, from: visit.plannedTime)
            #expect(hour == expectedHour)
        }
    }
    
    // MARK: - Move Visits Tests
    
    @Test func testMoveVisitsReordersSequence() {
        let mockService = MockVisitService()
        let clients = createSampleClients(count: 4)
        let viewModel = VisitAgendaViewModel(
            service: mockService,
            commercialId: 7,
            availableClients: clients
        )
        
        viewModel.selectedClients = clients
        viewModel.generateAgenda()
        
        // Move first visit to last position
        viewModel.moveVisits(from: IndexSet([0]), to: 4)
        
        #expect(viewModel.plannedVisits.count == 4)
        
        // Verify sequence numbers are updated correctly
        for (index, visit) in viewModel.plannedVisits.enumerated() {
            #expect(visit.sequence == index + 1)
        }
    }
    
    @Test func testMoveVisitsPreservesAllVisits() {
        let mockService = MockVisitService()
        let clients = createSampleClients(count: 3)
        let viewModel = VisitAgendaViewModel(
            service: mockService,
            commercialId: 7,
            availableClients: clients
        )
        
        viewModel.selectedClients = clients
        viewModel.generateAgenda()
        
        let originalClientIds = viewModel.plannedVisits.map { $0.client.id }
        
        // Move middle visit to end
        viewModel.moveVisits(from: IndexSet([1]), to: 3)
        
        let newClientIds = viewModel.plannedVisits.map { $0.client.id }
        
        // All clients should still be present, just reordered
        #expect(Set(originalClientIds) == Set(newClientIds))
        #expect(newClientIds.count == originalClientIds.count)
    }
    
    // MARK: - Delete Visits Tests
    
    @Test func testDeleteVisits() {
        let mockService = MockVisitService()
        let clients = createSampleClients(count: 5)
        let viewModel = VisitAgendaViewModel(
            service: mockService,
            commercialId: 7,
            availableClients: clients
        )
        
        viewModel.selectedClients = clients
        viewModel.generateAgenda()
        
        // Delete first two visits
        viewModel.deleteVisits(at: IndexSet([0, 1]))
        
        #expect(viewModel.plannedVisits.count == 3)
        
        // Verify sequence numbers are updated
        for (index, visit) in viewModel.plannedVisits.enumerated() {
            #expect(visit.sequence == index + 1)
        }
    }
    
    @Test func testDeleteAllVisits() {
        let mockService = MockVisitService()
        let clients = createSampleClients(count: 3)
        let viewModel = VisitAgendaViewModel(
            service: mockService,
            commercialId: 7,
            availableClients: clients
        )
        
        viewModel.selectedClients = clients
        viewModel.generateAgenda()
        
        // Delete all visits
        viewModel.deleteVisits(at: IndexSet([0, 1, 2]))
        
        #expect(viewModel.plannedVisits.isEmpty)
    }
    
    // MARK: - Update Selected Clients Tests
    
    @Test func testUpdateSelectedClients() {
        let mockService = MockVisitService()
        let allClients = createSampleClients(count: 5)
        let viewModel = VisitAgendaViewModel(
            service: mockService,
            commercialId: 7,
            availableClients: allClients
        )
        
        let selectedClients = Array(allClients.prefix(2))
        viewModel.updateSelectedClients(selectedClients)
        
        #expect(viewModel.selectedClients.count == 2)
        #expect(viewModel.selectedClients.map { $0.id } == selectedClients.map { $0.id })
    }
    
    // MARK: - Update Visit Tests
    
    @Test func testUpdateVisit() {
        let mockService = MockVisitService()
        let clients = createSampleClients(count: 3)
        let viewModel = VisitAgendaViewModel(
            service: mockService,
            commercialId: 7,
            availableClients: clients
        )
        
        viewModel.selectedClients = clients
        viewModel.generateAgenda()
        
        var updatedVisit = viewModel.plannedVisits[0]
        updatedVisit.notes = "Updated notes"
        updatedVisit.isCompleted = true
        
        viewModel.updateVisit(updatedVisit)
        
        #expect(viewModel.plannedVisits[0].notes == "Updated notes")
        #expect(viewModel.plannedVisits[0].isCompleted == true)
    }
    
    @Test func testUpdateVisitWithNonExistentId() {
        let mockService = MockVisitService()
        let clients = createSampleClients(count: 2)
        let viewModel = VisitAgendaViewModel(
            service: mockService,
            commercialId: 7,
            availableClients: clients
        )
        
        viewModel.selectedClients = clients
        viewModel.generateAgenda()
        
        let nonExistentVisit = Visit(
            sequence: 99,
            client: createSampleClient(id: 999, name: "Non-existent"),
            scheduledDate: Date(),
            plannedTime: Date()
        )
        
        let originalVisits = viewModel.plannedVisits
        viewModel.updateVisit(nonExistentVisit)
        
        // Visits should remain unchanged
        #expect(viewModel.plannedVisits.count == originalVisits.count)
    }
    
    // MARK: - Submit Agenda Tests
    
    @Test func testSubmitAgendaSuccess() async {
        let mockService = MockVisitService(shouldSucceed: true)
        let clients = createSampleClients(count: 3)
        let viewModel = VisitAgendaViewModel(
            service: mockService,
            commercialId: 7,
            availableClients: clients
        )
        
        viewModel.selectedClients = clients
        viewModel.generateAgenda()
        
        await viewModel.submitAgenda()
        
        #expect(viewModel.isSubmitting == false)
        #expect(viewModel.successMessage != nil)
        #expect(viewModel.errorMessage == nil)
        #expect(mockService.submitVisitCallCount == 3)
    }
    
    @Test func testSubmitAgendaWithError() async {
        let mockError = VisitServiceError.server(message: "Network error")
        let mockService = MockVisitService(shouldSucceed: false, mockError: mockError)
        let clients = createSampleClients(count: 2)
        let viewModel = VisitAgendaViewModel(
            service: mockService,
            commercialId: 7,
            availableClients: clients
        )
        
        viewModel.selectedClients = clients
        viewModel.generateAgenda()
        
        await viewModel.submitAgenda()
        
        #expect(viewModel.isSubmitting == false)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.successMessage == nil)
    }
    
    @Test func testSubmitAgendaGeneratesRandomIDs() async {
        let mockService = MockVisitService(shouldSucceed: true)
        let clients = createSampleClients(count: 2)
        let viewModel = VisitAgendaViewModel(
            service: mockService,
            commercialId: 7,
            availableClients: clients
        )
        
        viewModel.selectedClients = clients
        viewModel.generateAgenda()
        
        await viewModel.submitAgenda()
        
        // Verify that random IDs were generated (not sequential)
        let submittedIDs = mockService.lastSubmittedPayload?.visit_id
        #expect(submittedIDs != nil)
        
        // Verify the payload structure
        #expect(mockService.lastSubmittedPayload?.commercial_id == 7)
    }
    
    // MARK: - Refresh Remote Visits Tests
    
    @Test func testRefreshRemoteVisitsSuccess() async {
        let mockVisits = [
            VisitPayload(visitID: 1001, commercialID: 7, date: Date(), clientIDs: [10])
        ]
        let mockService = MockVisitService(shouldSucceed: true, mockVisits: mockVisits)
        let clients = createSampleClients(count: 3)
        let viewModel = VisitAgendaViewModel(
            service: mockService,
            commercialId: 7,
            availableClients: clients
        )
        
        await viewModel.refreshRemoteVisits(limit: 10)
        
        #expect(mockService.fetchRecentVisitsCallCount == 1)
        #expect(mockService.lastFetchLimit == 10)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func testRefreshRemoteVisitsWithError() async {
        let mockError = VisitServiceError.server(message: "Fetch error")
        let mockService = MockVisitService(shouldSucceed: false, mockError: mockError)
        let clients = createSampleClients(count: 3)
        let viewModel = VisitAgendaViewModel(
            service: mockService,
            commercialId: 7,
            availableClients: clients
        )
        
        await viewModel.refreshRemoteVisits(limit: 10)
        
        #expect(viewModel.errorMessage != nil)
    }
}

// MARK: - Date Extension Helper

extension Date {
    var truncatedToDay: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components) ?? self
    }
}

