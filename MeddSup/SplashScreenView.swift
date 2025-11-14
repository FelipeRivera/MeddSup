//
//  SplashScreenView.swift
//  MeddSup
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var backgroundOffset: CGFloat = -50
    
    var body: some View {
        ZStack {
            // Background with diagonal split
            DiagonalBackgroundView()
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Logo/Icon
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.9), Color.white.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "cross.case.fill")
                                .font(.system(size: 50, weight: .light))
                                .foregroundColor(.teal)
                        )
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // App Name
                    Text("MeddSup")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(textOpacity)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                
                Spacer()
                
                // Loading indicator
                VStack(spacing: 15) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                        .opacity(textOpacity)
                    
                    Text("Cargando...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(textOpacity)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeOut(duration: 0.8)) {
            logoScale = 1.0
            logoOpacity = 1.0
            backgroundOffset = 0
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
            textOpacity = 1.0
        }
        
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(1.0)) {
            isAnimating = true
        }
    }
}

#Preview {
    SplashScreenView()
}
