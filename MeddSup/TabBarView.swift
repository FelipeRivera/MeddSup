//
//  TabBarView.swift
//  MeddSup
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI
import ViewClientsModule
import LoginModule

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
    @State private var selectedTab: TabItem = .home
    @StateObject private var loginViewModel: LoginViewModel
    
    let baseURL: String
    let token: String
    let role: String
    
    init(baseURL: String, token: String, role: String, loginViewModel: LoginViewModel) {
        self.baseURL = baseURL
        self.token = token
        self.role = role
        self._loginViewModel = StateObject(wrappedValue: loginViewModel)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab - ViewClientsModule
            ViewClientsModule.createViewClientsView(
                baseURL: baseURL,
                token: token,
                role: role
            )
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
            
            // Notifications Tab - Placeholder
            NotificationsView()
                .tabItem {
                    Image(systemName: TabItem.notifications.systemImage)
                    Text(TabItem.notifications.title)
                }
                .tag(TabItem.notifications)
            
            // Profile Tab - Placeholder
            ProfileView(loginViewModel: loginViewModel)
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
        VStack {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(ViewClientsLocalizationHelper.shared.localizedString(for: "placeholder.search.title"))
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(ViewClientsLocalizationHelper.shared.localizedString(for: "placeholder.search.message"))
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.05))
    }
}

struct NotificationsView: View {
    var body: some View {
        VStack {
            Image(systemName: "bell")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(ViewClientsLocalizationHelper.shared.localizedString(for: "placeholder.notifications.title"))
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(ViewClientsLocalizationHelper.shared.localizedString(for: "placeholder.notifications.message"))
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.05))
    }
}

struct ProfileView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text(ViewClientsLocalizationHelper.shared.localizedString(for: "tabbar.profile"))
                .font(.title2)
                .fontWeight(.semibold)
            
            Button(ViewClientsLocalizationHelper.shared.localizedString(for: "tabbar.profile.logout")) {
                loginViewModel.logout()
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.black)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.05))
    }
}

#Preview {
    TabBarView(
        baseURL: "http://localhost:8080",
        token: "mock_token",
        role: "user",
        loginViewModel: LoginModule.createLoginViewModel(baseURL: "http://localhost:8080")
    )
}
