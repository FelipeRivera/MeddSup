//
//  ViewClientsView.swift
//  ViewClientsModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI

@available(iOS 16.0, *)
public struct ViewClientsView: View {
    @StateObject private var viewModel = ViewClientsViewModel(clientService: MockClientService())
    @State private var showingDatePicker = false
    @State private var tempSelectedDate: Date = Date()
    
    let baseURL: String
    let token: String
    let role: String
    
    public init(baseURL: String, token: String, role: String) {
        self.baseURL = baseURL
        self.token = token
        self.role = role
    }
    
    private var datePickerSheet: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "",
                    selection: $tempSelectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String.localized("viewclients.date.picker.cancel")) {
                        showingDatePicker = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String.localized("viewclients.date.picker.accept")) {
                        viewModel.selectedDate = tempSelectedDate
                        viewModel.refreshFilters()
                        showingDatePicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            // Black header bar
            Rectangle()
                .fill(Color.black)
                .frame(height: 60)
                .overlay(
                    HStack {
                        Text(verbatim: .localized("viewclients.header.title"))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                )
            
            // Main title section
            HStack {
                Image(systemName: "map.fill")
                    .foregroundColor(.black)
                    .font(.system(size: 20))
                
                Text(verbatim: .localized("viewclients.main.title"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Spacer()
                
                configureButton
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
        }
    }
    
    private var configureButton: some View {
        Button(String.localized("viewclients.configure.button")) {
            // TODO: Implement configuration
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black)
        .cornerRadius(8)
    }
    
    private var mainContentSection: some View {
        VStack(spacing: 20) {
            dateSelectionSection
            searchBarSection
            loadingSection
            errorSection
            clientsListSection
        }
        .background(Color.gray.opacity(0.05))
    }
    
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: .localized("viewclients.date.label"))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            datePickerButton
        }
    }
    
    private var datePickerButton: some View {
        Button(action: {
            tempSelectedDate = viewModel.selectedDate
            showingDatePicker = true
        }) {
            HStack {
                Text(viewModel.formatDate(viewModel.selectedDate))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }
    
    private var searchBarSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField(String.localized("viewclients.search.placeholder"), text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
    
    private var loadingSection: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .scaleEffect(1.2)
                    .padding()
            }
        }
    }
    
    private var errorSection: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private var clientsListSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredClients) { client in
                    ClientCardView(client: client)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    public var body: some View {
        ZStack {
            DiagonalBackgroundView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                mainContentSection
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            datePickerSheet
        }
        .onAppear {
            viewModel.loadClients(baseURL: baseURL, token: token, role: role)
        }
    }
}

// MARK: - Client Card View
struct ClientCardView: View {
    let client: Client
    
    private var locationIcon: some View {
        Image(systemName: "location.fill")
            .foregroundColor(.gray)
            .font(.system(size: 14))
            .frame(width: 16)
    }
    
    private var addressText: some View {
        Text(String.localized("viewclients.client.address", arguments: client.address))
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.black)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
    
    private var clockIcon: some View {
        Image(systemName: "clock.fill")
            .foregroundColor(.gray)
            .font(.system(size: 14))
            .frame(width: 16)
    }
    
    private var scheduleText: some View {
        Text(String.localized("viewclients.client.schedule", arguments: client.schedule))
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.black)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
    
    private var carIcon: some View {
        Image(systemName: "car.fill")
            .foregroundColor(.gray)
            .font(.system(size: 14))
            .frame(width: 16)
    }
    
    private var travelTimeText: some View {
        Text(String.localized("viewclients.client.travel.time", arguments: client.travelTime))
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.black)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(client.name)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    locationIcon
                    
                    addressText
                }
                
                HStack(alignment: .top, spacing: 8) {
                    clockIcon
                    
                    scheduleText
                }
                
                HStack(alignment: .top, spacing: 8) {
                    carIcon
                    
                    travelTimeText
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Diagonal Background (reused from LoginView)
struct DiagonalBackgroundView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.teal.opacity(0.3),
                            Color.teal.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .overlay(
                    DiagonalLinesPattern()
                        .opacity(0.2)
                )
                .clipShape(
                    TriangleShape()
                        .rotation(.degrees(45))
                )
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.2),
                            Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.1)
                        ],
                        startPoint: .center,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(
                    TriangleShape()
                        .rotation(.degrees(225))
                )
        }
    }
}

struct DiagonalLinesPattern: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let spacing: CGFloat = 8
                
                for i in stride(from: -width, through: width + height, by: spacing) {
                    path.move(to: CGPoint(x: i, y: 0))
                    path.addLine(to: CGPoint(x: i + height, y: height))
                }
            }
            .stroke(Color.white.opacity(0.2), lineWidth: 1)
        }
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ViewClientsView(
        baseURL: "http://localhost:8080",
        token: "mock_token",
        role: "user"
    )
}
