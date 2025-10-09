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
        simulateAppInitialization()
    }
    
    private func simulateAppInitialization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                self.isLoading = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.isShowingSplash = false
                }
            }
        }
    }
    
    func hideSplashScreen() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isShowingSplash = false
        }
    }
    
    func showSplashScreen() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isShowingSplash = true
            isLoading = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.simulateAppInitialization()
        }
    }
}
