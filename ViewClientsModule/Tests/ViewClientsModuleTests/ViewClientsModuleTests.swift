import Foundation
import Testing
import Combine
@testable import ViewClientsModule

@MainActor
struct ViewClientsViewModelTests {
    
    // MARK: - Helpers
    private func makeClients() -> [Client] {
        return [
            Client(id: "1", name: "Alice", address: "123 Apple St", schedule: "2025-10-20 9:00am - 11:00am", travelTime: "10m"),
            Client(id: "2", name: "Bob", address: "742 Evergreen Terrace", schedule: "2025-10-20 11:00am - 1:00pm", travelTime: "20m"),
            Client(id: "3", name: "Carlos", address: "Miami Beach Ave", schedule: "2025-10-21 9:00am - 11:00am", travelTime: "15m")
        ]
    }
    
    private func makeClientsWithDifferentDates() -> [Client] {
        return [
            Client(id: "1", name: "Alice", address: "123 Apple St", schedule: "2025-10-20 9:00am - 11:00am", travelTime: "10m"),
            Client(id: "2", name: "Bob", address: "742 Evergreen Terrace", schedule: "2025-10-20 11:00am - 1:00pm", travelTime: "20m"),
            Client(id: "3", name: "Carlos", address: "Miami Beach Ave", schedule: "2025-10-21 9:00am - 11:00am", travelTime: "15m"),
            Client(id: "4", name: "Diana", address: "456 Oak St", schedule: "2025-10-21 11:00am - 1:00pm", travelTime: "25m"),
            Client(id: "5", name: "Eve", address: "789 Pine St", schedule: "2025-10-22 9:00am - 11:00am", travelTime: "15m")
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
        
        // Set date to 2025-10-20 to match test data
        var components = DateComponents()
        components.year = 2025
        components.month = 10
        components.day = 20
        vm.selectedDate = Calendar.current.date(from: components)!
        
        vm.loadClients(baseURL: "https://example.com", token: "token", role: "roleA")
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
        #expect(vm.clients.count == clients.count)
        // Filtered by date: only Alice and Bob (both 2025-10-20)
        #expect(vm.filteredClients.count == 2)
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
        
        // Set date to 2025-10-21 to get Carlos (who has Miami address)
        var components = DateComponents()
        components.year = 2025
        components.month = 10
        components.day = 21
        vm.selectedDate = Calendar.current.date(from: components)!
        
        vm.loadClients(baseURL: "https://example.com", token: "token", role: "r")
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Change to 2025-10-20 for Alice
        components.day = 20
        vm.selectedDate = Calendar.current.date(from: components)!
        vm.refreshFilters()
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        vm.searchText = "alice"
        try? await Task.sleep(nanoseconds: 400_000_000)
        #expect(vm.filteredClients.map{ $0.name }.contains("Alice"))
        
        // Change to 2025-10-21 and search for miami
        components.day = 21
        vm.selectedDate = Calendar.current.date(from: components)!
        vm.searchText = "miami"
        try? await Task.sleep(nanoseconds: 400_000_000)
        #expect(vm.filteredClients.map{ $0.address }.contains(where: { $0.contains("Miami") }))
    }
    
    @Test func testClearSearchResetsFilter() async {
        let clients = makeClients()
        let service = SimpleMockClientService(result: .success(clients))
        let vm = ViewClientsViewModel(clientService: service)
        
        // Set date to 2025-10-20 to match Alice and Bob
        var components = DateComponents()
        components.year = 2025
        components.month = 10
        components.day = 20
        vm.selectedDate = Calendar.current.date(from: components)!
        
        vm.loadClients(baseURL: "https://example.com", token: "token", role: "r")
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        vm.searchText = "zzz"
        try? await Task.sleep(nanoseconds: 400_000_000)
        #expect(vm.filteredClients.isEmpty)
        
        vm.clearSearch()
        try? await Task.sleep(nanoseconds: 50_000_000)
        // After clearing search, still filtered by date (Alice and Bob)
        #expect(vm.filteredClients.count == 2)
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
    
    // MARK: - Date Filtering
    @Test func testFilterByDate_ShowsOnlyClientsForSelectedDate() async {
        let clients = makeClientsWithDifferentDates()
        let service = SimpleMockClientService(result: .success(clients))
        let vm = ViewClientsViewModel(clientService: service)
        
        // Load clients first
        vm.loadClients(baseURL: "https://example.com", token: "token", role: "role")
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Set date to 2025-10-20
        var components = DateComponents()
        components.year = 2025
        components.month = 10
        components.day = 20
        let date20 = Calendar.current.date(from: components)!
        
        vm.selectedDate = date20
        vm.refreshFilters()
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Should only show Alice and Bob (both have 2025-10-20)
        #expect(vm.filteredClients.count == 2)
        #expect(vm.filteredClients.contains(where: { $0.name == "Alice" }))
        #expect(vm.filteredClients.contains(where: { $0.name == "Bob" }))
    }
    
    @Test func testFilterByDate_ChangingDateUpdatesResults() async {
        let clients = makeClientsWithDifferentDates()
        let service = SimpleMockClientService(result: .success(clients))
        let vm = ViewClientsViewModel(clientService: service)
        
        vm.loadClients(baseURL: "https://example.com", token: "token", role: "role")
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Set date to 2025-10-21
        var components = DateComponents()
        components.year = 2025
        components.month = 10
        components.day = 21
        let date21 = Calendar.current.date(from: components)!
        
        vm.selectedDate = date21
        vm.refreshFilters()
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Should only show Carlos and Diana (both have 2025-10-21)
        #expect(vm.filteredClients.count == 2)
        #expect(vm.filteredClients.contains(where: { $0.name == "Carlos" }))
        #expect(vm.filteredClients.contains(where: { $0.name == "Diana" }))
        
        // Change date to 2025-10-22
        components.day = 22
        let date22 = Calendar.current.date(from: components)!
        
        vm.selectedDate = date22
        vm.refreshFilters()
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Should only show Eve
        #expect(vm.filteredClients.count == 1)
        #expect(vm.filteredClients.first?.name == "Eve")
    }
    
    @Test func testFilterByDate_NoClientsForSelectedDate() async {
        let clients = makeClientsWithDifferentDates()
        let service = SimpleMockClientService(result: .success(clients))
        let vm = ViewClientsViewModel(clientService: service)
        
        vm.loadClients(baseURL: "https://example.com", token: "token", role: "role")
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Set date to 2025-10-25 (no clients for this date)
        var components = DateComponents()
        components.year = 2025
        components.month = 10
        components.day = 25
        let date25 = Calendar.current.date(from: components)!
        
        vm.selectedDate = date25
        vm.refreshFilters()
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Should show no clients
        #expect(vm.filteredClients.isEmpty)
    }
    
    @Test func testFilterByDateAndSearch_CombinesBothFilters() async {
        let clients = makeClientsWithDifferentDates()
        let service = SimpleMockClientService(result: .success(clients))
        let vm = ViewClientsViewModel(clientService: service)
        
        vm.loadClients(baseURL: "https://example.com", token: "token", role: "role")
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Set date to 2025-10-20 (Alice and Bob)
        var components = DateComponents()
        components.year = 2025
        components.month = 10
        components.day = 20
        let date20 = Calendar.current.date(from: components)!
        
        vm.selectedDate = date20
        vm.refreshFilters()
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        #expect(vm.filteredClients.count == 2)
        
        // Now add search filter
        vm.searchText = "alice"
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Should only show Alice (matches date AND search)
        #expect(vm.filteredClients.count == 1)
        #expect(vm.filteredClients.first?.name == "Alice")
    }
    
    @Test func testRefreshFilters_AppliesCurrentFilters() async {
        let clients = makeClientsWithDifferentDates()
        let service = SimpleMockClientService(result: .success(clients))
        let vm = ViewClientsViewModel(clientService: service)
        
        vm.loadClients(baseURL: "https://example.com", token: "token", role: "role")
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Set date to 2025-10-21
        var components = DateComponents()
        components.year = 2025
        components.month = 10
        components.day = 21
        let date21 = Calendar.current.date(from: components)!
        
        vm.selectedDate = date21
        
        // Manually call refreshFilters
        vm.refreshFilters()
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Should show Carlos and Diana
        #expect(vm.filteredClients.count == 2)
        #expect(vm.filteredClients.contains(where: { $0.name == "Carlos" }))
        #expect(vm.filteredClients.contains(where: { $0.name == "Diana" }))
    }
}
