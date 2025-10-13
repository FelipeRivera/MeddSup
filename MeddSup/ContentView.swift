//
//  ContentView.swift
//  MeddSup
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI
import RouteMapKit
import LoginModule
import ViewClientsModule

struct ContentView: View {
    let routesApi = RouteAPI(baseURL: URL(string: "http://localhost:8080")!)
    
    @StateObject private var loginViewModel = LoginModule.createLoginViewModel(baseURL: "http://portal-web-alb-701001447.us-east-1.elb.amazonaws.com/auth")
    
    var body: some View {
        Group {
            if loginViewModel.isLoggedIn {
                TabBarView(
                    baseURL: "http://portal-web-alb-701001447.us-east-1.elb.amazonaws.com",
                    token: loginViewModel.authToken ?? "",
                    role: loginViewModel.userRole ?? "user",
                    loginViewModel: loginViewModel
                )
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
