//
//  VisitAgendaViewModel.swift
//  VisitLogModule
//
//  Created by GPT-5.1 Codex on 15/11/25.
//

import Foundation
import Combine

/// Handles the Planear Visitas workflow (agenda generation, persistence and submission).
@MainActor
public final class VisitAgendaViewModel: ObservableObject {
    @Published public var selectedDate: Date = Date()
    @Published public var selectedClients: [Client] = []
    @Published public var plannedVisits: [Visit] = []
    @Published public var isSubmitting: Bool = false
    @Published public var isGenerating: Bool = false
    @Published public var errorMessage: String?
    @Published public var successMessage: String?
    @Published public var activeVisit: Visit?
    @Published public var reportFilter: ReportFilter = .byPeriod
    
    public enum ReportFilter: String, CaseIterable, Identifiable {
        case byPeriod
        case byInstitution
        
        public var id: String { rawValue }
        
        public var localizationKey: String {
            switch self {
            case .byPeriod:
                return "visitroute.report.radio.period"
            case .byInstitution:
                return "visitroute.report.radio.institution"
            }
        }
    }
    
    public var availableClients: [Client]
    
    private let service: VisitServiceProtocol
    private let commercialId: Int
    private let storageKey = "visitlogmodule.plannedVisits"
    private let localization = VisitLogLocalizationHelper.shared
    
    public init(
        service: VisitServiceProtocol,
        commercialId: Int = 7,
        preloadedVisits: [Visit] = [],
        availableClients: [Client]) {
            self.service = service
            self.commercialId = commercialId
            self.plannedVisits = preloadedVisits
            self.availableClients = availableClients
            if preloadedVisits.isEmpty {
                loadPersistedVisits()
            }
            if availableClients.isEmpty {
                self.availableClients = defaultClients()
            }
        }
    
    /// Generates a new agenda using the selected clients and date.
    public func generateAgenda() {
        guard selectedClients.isEmpty == false else {
            errorMessage = localization.localizedString(for: "visitroute.error.no.clients")
            return
        }
        
        isGenerating = true
        defer { isGenerating = false }
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        var visits: [Visit] = []
        let baseStartHour = 9
        
        for (index, client) in selectedClients.enumerated() {
            let visitDate = calendar.date(
                bySettingHour: baseStartHour + index,
                minute: 0,
                second: 0,
                of: selectedDate
            ) ?? selectedDate
            
            let visit = Visit(
                sequence: index + 1,
                client: client,
                scheduledDate: selectedDate,
                plannedTime: visitDate
            )
            visits.append(visit)
        }
        
        plannedVisits = visits
        persistVisits()
    }
    
    /// Persists the planned visits in UserDefaults to keep state between sessions.
    private func persistVisits() {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(plannedVisits) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    private func loadPersistedVisits() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let visits = try? JSONDecoder().decode([Visit].self, from: data)
        else {
            return
        }
        plannedVisits = visits
        var uniqueClients: [Client] = []
        for visit in visits where uniqueClients.contains(where: { $0.id == visit.client.id }) == false {
            uniqueClients.append(visit.client)
        }
        selectedClients = uniqueClients
    }
    
    /// Updates the planned visits order (drag and drop support).
    public func moveVisits(from source: IndexSet, to destination: Int) {
        plannedVisits.move(fromOffsets: source, toOffset: destination)
        for idx in plannedVisits.indices {
            plannedVisits[idx].sequence = idx + 1
        }
        persistVisits()
    }
    
    /// Removes visits from the agenda.
    public func deleteVisits(at offsets: IndexSet) {
        plannedVisits.remove(atOffsets: offsets)
        for idx in plannedVisits.indices {
            plannedVisits[idx].sequence = idx + 1
        }
        persistVisits()
    }
    
    /// Updates the selected clients list from the selection modal.
    public func updateSelectedClients(_ clients: [Client]) {
        selectedClients = clients
    }
    
    /// Refreshes planned visits after an update coming from the detail screen.
    public func updateVisit(_ visit: Visit) {
        if let index = plannedVisits.firstIndex(where: { $0.id == visit.id }) {
            plannedVisits[index] = visit
            persistVisits()
        }
    }
    
    /// Sends every visit to the backend service.
    public func submitAgenda() async {
        guard plannedVisits.isEmpty == false else {
            errorMessage = localization.localizedString(for: "visitroute.error.no.visits")
            return
        }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            for (index, visit) in plannedVisits.enumerated() {
                let payload = VisitPayload(
                    visitID: index + 1000,
                    commercialID: commercialId,
                    date: visit.plannedTime,
                    clientIDs: [visit.client.id]
                )
                try await service.submitVisit(payload)
            }
            
            successMessage = localization.localizedString(for: "visitroute.success.submit")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Loads the most recent visits from the backend (optional dashboard usage).
    public func refreshRemoteVisits(limit: Int = 10) async {
        do {
            _ = try await service.fetchRecentVisits(limit: limit)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Sample Data
extension VisitAgendaViewModel {
    func defaultClients() -> [Client] {
        [
            Client(id: 10, name: "Clínica Andes", address: "Av. Libertad 123, Santiago", latitude: -33.4569, longitude: -70.6483),
            Client(id: 20, name: "Hospital Central", address: "Cra 7 # 40-62, Bogotá", latitude: 4.6486, longitude: -74.0995),
            Client(id: 30, name: "Instituto del Corazón", address: "Calle 26 # 52-20, Ciudad de México", latitude: 19.4326, longitude: -99.1332),
            Client(id: 40, name: "Centro Médico Pacífico", address: "Av. Javier Prado 776, Lima", latitude: -12.0464, longitude: -77.0428),
            Client(id: 50, name: "Hospital del Sur", address: "Av. 9 de Julio 999, Buenos Aires", latitude: -34.6037, longitude: -58.3816)
        ]
    }
}
