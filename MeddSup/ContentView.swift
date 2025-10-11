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
    
    @StateObject private var loginViewModel = LoginModule.createLoginViewModel(baseURL: "http://portal-web-alb-701001447.us-east-1.elb.amazonaws.com/auth")
    
    var body: some View {
        Group {
            if loginViewModel.isLoggedIn {
                VStack {
                    Button("Test Log out") {
                        loginViewModel.logout()
                    }
                    NavigationStack {
                        RouteMapScreen(api: routesApi)
                    }
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
