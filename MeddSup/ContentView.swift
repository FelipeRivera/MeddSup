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
    let routesApi = RouteAPI(baseURL: URL(string: "http://localhost:8080")!)
    
    @StateObject private var loginViewModel = LoginModule.createLoginViewModel(baseURL: "http://localhost:8080")
    
    var body: some View {
        Group {
            if loginViewModel.isLoggedIn {
                NavigationStack {
                    RouteMapScreen(api: routesApi)
                }
            } else {
                LoginView()
                    .environmentObject(loginViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
