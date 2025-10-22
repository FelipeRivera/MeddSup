//
//  ViewClientsViewModel.swift
//  ViewClientsModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation
import Combine

@available(iOS 15.0, *)
@MainActor
public class ViewClientsViewModel: ObservableObject {
    @Published public var clients: [Client] = []
    @Published public var filteredClients: [Client] = []
    @Published public var searchText: String = ""
    @Published public var selectedDate: Date = Date()
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var role: String = ""
    
    private let clientService: ClientServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var searchCancellable: AnyCancellable?
    
    public init(clientService: ClientServiceProtocol = ClientService()) {
        self.clientService = clientService
        setupSearchDebounce()
        setupDateFilter()
    }
    
    private func setupSearchDebounce() {
        searchCancellable = $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyFilters()
            }
    }
    
    private func setupDateFilter() {
        $selectedDate
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    private func applyFilters() {
        Task { @MainActor in
            var result = clients
            
            // Filter by date
            result = filterByDate(clients: result)
            
            // Filter by search text
            if !searchText.isEmpty {
                result = result.filter { client in
                    client.name.localizedCaseInsensitiveContains(searchText) ||
                    client.address.localizedCaseInsensitiveContains(searchText)
                }
            }
            
            filteredClients = result
        }
    }
    
    private func filterByDate(clients: [Client]) -> [Client] {
        let selectedDateString = formatDate(selectedDate)
        
        return clients.filter { client in
            extractDate(from: client.schedule) == selectedDateString
        }
    }
    
    private func extractDate(from schedule: String) -> String? {
        let components = schedule.components(separatedBy: " ")
        if let dateString = components.first, dateString.count == 10 {
            return dateString
        }
        return nil
    }
    
    private func filterClients(searchText: String) {
        applyFilters()
    }
    
    public func loadClients(baseURL: String, token: String, role: String) {
        guard !baseURL.isEmpty, !token.isEmpty, !role.isEmpty else {
            errorMessage = "Missing required parameters"
            return
        }
        
        self.role = role
        isLoading = true
        errorMessage = nil
        
        clientService.fetchClients(baseURL: baseURL, token: token, role: role)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] clients in
                    self?.clients = clients
                    self?.applyFilters()
                }
            )
            .store(in: &cancellables)
    }
    
    public func refreshClients(baseURL: String, token: String) {
        loadClients(baseURL: baseURL, token: token, role: role)
    }
    
    public func clearSearch() {
        searchText = ""
        applyFilters()
    }
    
    public func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    public func refreshFilters() {
        applyFilters()
    }
}
