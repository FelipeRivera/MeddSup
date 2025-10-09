//
//  MeddSupApp.swift
//  MeddSup
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI

@main
struct MeddSupApp: App {
    @StateObject private var splashScreenManager = SplashScreenManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if splashScreenManager.isShowingSplash {
                    SplashScreenView()
                        .transition(.opacity)
                } else {
                    ContentView()
                        .transition(.opacity)
                }
            }
            .environmentObject(splashScreenManager)
        }
    }
}
