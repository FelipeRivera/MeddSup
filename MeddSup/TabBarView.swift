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
            return "Consulta de Rutas"
        case .search:
            return "Buscar"
        case .notifications:
            return "Notificaciones"
        case .profile:
            return "Perfil"
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
            
            Text("Buscar")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Esta funcionalidad estará disponible próximamente")
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
            
            Text("Notificaciones")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Esta funcionalidad estará disponible próximamente")
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
            
            Text("Perfil")
                .font(.title2)
                .fontWeight(.semibold)
            
            Button("Cerrar Sesión") {
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
