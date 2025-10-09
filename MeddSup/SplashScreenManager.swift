//
//  SplashScreenManager.swift
//  MeddSup
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI
import Combine

class SplashScreenManager: ObservableObject {
    @Published var isShowingSplash = true
    @Published var isLoading = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Simulate app initialization time
        simulateAppInitialization()
    }
    
    private func simulateAppInitialization() {
        // Simulate network calls, data loading, etc.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                self.isLoading = false
            }
            
            // Hide splash screen after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.isShowingSplash = false
                }
            }
        }
    }
    
    // Method to manually hide splash screen (useful for testing)
    func hideSplashScreen() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isShowingSplash = false
        }
    }
    
    // Method to show splash screen again (useful for logout scenarios)
    func showSplashScreen() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isShowingSplash = true
            isLoading = true
        }
        
        // Reset after showing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.simulateAppInitialization()
        }
    }
}
