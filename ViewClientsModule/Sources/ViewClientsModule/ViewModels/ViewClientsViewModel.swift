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
    }
    
    private func setupSearchDebounce() {
        searchCancellable = $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.filterClients(searchText: searchText)
            }
    }
    
    private func filterClients(searchText: String) {
        if searchText.isEmpty {
            filteredClients = clients
        } else {
            filteredClients = clients.filter { client in
                client.name.localizedCaseInsensitiveContains(searchText) ||
                client.address.localizedCaseInsensitiveContains(searchText)
            }
        }
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
                    self?.filteredClients = clients
                }
            )
            .store(in: &cancellables)
    }
    
    public func refreshClients(baseURL: String, token: String) {
        loadClients(baseURL: baseURL, token: token, role: role)
    }
    
    public func clearSearch() {
        searchText = ""
    }
    
    public func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
