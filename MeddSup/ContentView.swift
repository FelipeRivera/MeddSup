//
//  ContentView.swift
//  MeddSup
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI
import RouteMapKit
import LoginModule

struct ContentView: View {
    @StateObject private var configuration = ConfigurationManager.shared
    @StateObject private var moduleFactory = ModuleFactory()
    @StateObject private var loginViewModel: LoginViewModel
    
    init() {
        // Initialize login view model with configuration
        let loginVM = LoginModule.createLoginViewModel(
            baseURL: ConfigurationManager.shared.endpoints.authBaseURL
        )
        self._loginViewModel = StateObject(wrappedValue: loginVM)
    }
    
    var body: some View {
        Group {
            if configuration.userSession != nil {
                TabBarView()
                    .environmentObject(configuration)
                    .environmentObject(moduleFactory)
                    .environmentObject(loginViewModel)
            } else {
                LoginView()
                    .environmentObject(loginViewModel)
                    .onReceive(loginViewModel.$isLoggedIn) { isLoggedIn in
                        if isLoggedIn {
                            configuration.updateUserSession(
                                token: loginViewModel.authToken ?? "",
                                role: loginViewModel.userRole ?? "user"
                            )
                        }
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
