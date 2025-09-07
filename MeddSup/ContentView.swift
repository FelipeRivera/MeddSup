//
//  ContentView.swift
//  MeddSup
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI
import RouteMapKit

struct ContentView: View {
    let api = RouteAPI(baseURL: URL(string: "http://localhost:8080")!)
    
    var body: some View {
        NavigationStack {
            RouteMapScreen(api: api)
        }
    }
}

#Preview {
    ContentView()
}
