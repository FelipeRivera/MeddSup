//
//  TabBarView.swift
//  MeddSup
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI
import ViewClientsModule
import LoginModule
import OrderStatusModule

enum TabItem: CaseIterable {
    case home
    case search
    case notifications
    case profile
    
    var title: String {
        switch self {
        case .home:
            return ViewClientsLocalizationHelper.shared.localizedString(for: "tabbar.home")
        case .search:
            return ViewClientsLocalizationHelper.shared.localizedString(for: "tabbar.search")
        case .notifications:
            return ViewClientsLocalizationHelper.shared.localizedString(for: "tabbar.notifications")
        case .profile:
            return ViewClientsLocalizationHelper.shared.localizedString(for: "tabbar.profile")
        }
    }
    
    var systemImage: String {
        switch self {
        case .home:
            return "house.fill"
        case .search:
            return "magnifyingglass"
        case .notifications:
            return "bell"
        case .profile:
            return "person"
        }
    }
}

@available(iOS 15.0, *)
struct TabBarView: View {
    @EnvironmentObject private var configuration: ConfigurationManager
    @EnvironmentObject private var moduleFactory: ModuleFactory
    @EnvironmentObject private var loginViewModel: LoginViewModel
    @State private var selectedTab: TabItem = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab - ViewClientsModule
            moduleFactory.createViewClientsModule()
                .tabItem {
                    Image(systemName: TabItem.home.systemImage)
                    Text(TabItem.home.title)
                }
                .tag(TabItem.home)
            
            // Search Tab - Placeholder
            SearchView()
                .tabItem {
                    Image(systemName: TabItem.search.systemImage)
                    Text(TabItem.search.title)
                }
                .tag(TabItem.search)
            
            // Notifications Tab - OrderStatusModule
            moduleFactory.createOrderStatusModule()
                .tabItem {
                    Image(systemName: TabItem.notifications.systemImage)
                    Text(TabItem.notifications.title)
                }
                .tag(TabItem.notifications)
            
            // Profile Tab - Placeholder
            ProfileView()
                .environmentObject(configuration)
                .environmentObject(loginViewModel)
                .tabItem {
                    Image(systemName: TabItem.profile.systemImage)
                    Text(TabItem.profile.title)
                }
                .tag(TabItem.profile)
        }
        .accentColor(.black)
    }
}

// MARK: - Placeholder Views
struct SearchView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text(ViewClientsLocalizationHelper.shared.localizedString(for: "tabbar.search"))
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(ViewClientsLocalizationHelper.shared.localizedString(for: "tabbar.search.description"))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.05))
    }
}

struct ProfileView: View {
    @EnvironmentObject private var configuration: ConfigurationManager
    @EnvironmentObject private var loginViewModel: LoginViewModel
    @EnvironmentObject private var moduleFactory: ModuleFactory
    @State private var showCreateOrder = false
    @State private var showCustomerRegistration = false
    
    var body: some View {
        ZStack {
            DiagonalBackgroundView()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "person.circle")
                    .font(.system(size: 80))
                    .foregroundColor(.gray)
                
                Text(ViewClientsLocalizationHelper.shared.localizedString(for: "tabbar.profile"))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Button(ViewClientsLocalizationHelper.shared.localizedString(for: "tabbar.profile.register.client")) {
                    showCustomerRegistration = true
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(8)
                
                Button(ViewClientsLocalizationHelper.shared.localizedString(for: "tabbar.profile.create.order")) {
                    showCreateOrder = true
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(8)
                
                Button(ViewClientsLocalizationHelper.shared.localizedString(for: "tabbar.profile.logout")) {
                    // Clear both configuration and login view model
                    configuration.clearUserSession()
                    loginViewModel.logout()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.black)
                .cornerRadius(8)
            }
        }
        .sheet(isPresented: $showCustomerRegistration) {
            NavigationView {
                moduleFactory.createCustomerRegistrationModule()
            }
        }
        .sheet(isPresented: $showCreateOrder) {
            NavigationView {
                moduleFactory.createCreateOrderModule()
            }
        }
    }
}

// MARK: - Diagonal Background View
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
    TabBarView()
        .environmentObject(ConfigurationManager.shared)
        .environmentObject(ModuleFactory())
        .environmentObject(LoginModule.createLoginViewModel(baseURL: "http://localhost:8080"))
}