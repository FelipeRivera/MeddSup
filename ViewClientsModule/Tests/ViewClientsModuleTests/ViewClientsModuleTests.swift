import Foundation
import Testing
import Combine
@testable import ViewClientsModule

@MainActor
struct ViewClientsViewModelTests {
    
    // MARK: - Helpers
    private func makeClients() -> [Client] {
        return [
            Client(id: "1", name: "Alice", address: "123 Apple St", schedule: "09-10", travelTime: "10m"),
            Client(id: "2", name: "Bob", address: "742 Evergreen Terrace", schedule: "10-11", travelTime: "20m"),
            Client(id: "3", name: "Carlos", address: "Miami Beach Ave", schedule: "11-12", travelTime: "15m")
        ]
    }
    
    // MARK: - Initial State
    @Test func testInitialState() {
        let service = SimpleMockClientService(result: .success([]))
        let vm = ViewClientsViewModel(clientService: service)
        
        #expect(vm.clients.isEmpty)
        #expect(vm.filteredClients.isEmpty)
        #expect(vm.searchText == "")
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
        #expect(vm.role == "")
    }
    
    // MARK: - Load Clients Success
    @Test func testLoadClientsSuccess() async {
        let clients = makeClients()
        let service = SimpleMockClientService(result: .success(clients))
        let vm = ViewClientsViewModel(clientService: service)
        
        vm.loadClients(baseURL: "https://example.com", token: "token", role: "roleA")
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
        #expect(vm.clients.count == clients.count)
        #expect(vm.filteredClients.count == clients.count)
        #expect(vm.role == "roleA")
    }
    
    // MARK: - Load Clients Missing Params
    @Test func testLoadClientsMissingParams() {
        let service = SimpleMockClientService(result: .success(makeClients()))
        let vm = ViewClientsViewModel(clientService: service)
        
        vm.loadClients(baseURL: "", token: "", role: "")
        
        #expect(vm.errorMessage == "Missing required parameters")
        #expect(vm.isLoading == false)
        #expect(vm.clients.isEmpty)
    }
    
    // MARK: - Load Clients Failure
    @Test func testLoadClientsFailure() async {
        let service = SimpleMockClientService(result: .failure(.networkError("down")))
        let vm = ViewClientsViewModel(clientService: service)
        
        vm.loadClients(baseURL: "https://example.com", token: "token", role: "roleB")
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        #expect(vm.isLoading == false)
        #expect(vm.clients.isEmpty)
        #expect(vm.filteredClients.isEmpty)
        #expect(vm.errorMessage?.contains("Network error") == true)
    }
    
    // MARK: - Search Filtering
    @Test func testSearchFiltersByNameAndAddress() async {
        let clients = makeClients()
        let service = SimpleMockClientService(result: .success(clients))
        let vm = ViewClientsViewModel(clientService: service)
        
        vm.loadClients(baseURL: "https://example.com", token: "token", role: "r")
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        vm.searchText = "alice"
        try? await Task.sleep(nanoseconds: 400_000_000)
        #expect(vm.filteredClients.map{ $0.name }.contains("Alice"))
        
        vm.searchText = "miami"
        try? await Task.sleep(nanoseconds: 400_000_000)
        #expect(vm.filteredClients.map{ $0.address }.contains(where: { $0.contains("Miami") }))
    }
    
    @Test func testClearSearchResetsFilter() async {
        let clients = makeClients()
        let service = SimpleMockClientService(result: .success(clients))
        let vm = ViewClientsViewModel(clientService: service)
        
        vm.loadClients(baseURL: "https://example.com", token: "token", role: "r")
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        vm.searchText = "zzz"
        try? await Task.sleep(nanoseconds: 400_000_000)
        #expect(vm.filteredClients.isEmpty)
        
        vm.clearSearch()
        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(vm.filteredClients.count == clients.count)
    }
    
    // MARK: - Refresh uses last role
    @Test func testRefreshUsesStoredRole() async {
        let clients = makeClients()
        let service = SimpleMockClientService(result: .success(clients))
        let vm = ViewClientsViewModel(clientService: service)
        
        vm.loadClients(baseURL: "https://example.com", token: "token", role: "firstRole")
        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(vm.role == "firstRole")
        
        vm.refreshClients(baseURL: "https://example.com", token: "token2")
        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(vm.role == "firstRole")
    }
    
    // MARK: - Date formatting
    @Test func testFormatDate() {
        let service = SimpleMockClientService(result: .success([]))
        let vm = ViewClientsViewModel(clientService: service)
        
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 2
        let date = Calendar.current.date(from: components)!
        
        #expect(vm.formatDate(date) == "2025-01-02")
    }
}
