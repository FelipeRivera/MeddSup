//
//  LoginView.swift
//  LoginModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI
import UIKit

@available(iOS 15.0, macOS 10.15, *)
public struct LoginView: View {
    @EnvironmentObject private var viewModel: LoginViewModel
    @State private var showPassword = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            DiagonalBackgroundView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    // Black header bar
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 60)
                        .overlay(
                            HStack {
                                Text(verbatim: .localized("login.header.title"))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                                .padding(.horizontal, 20)
                        )
                    
                    // App title
                    VStack(spacing: 8) {
                        Text(verbatim: .localized("app.title"))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    }
                    .padding(.vertical, 30)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                }
                
                // Main content area
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Login form
                    VStack(spacing: 20) {
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            TextField(String.localized("email.placeholder"), text: $viewModel.email)
                                .textFieldStyle(LoginTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .password
                                }
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                if showPassword {
                                    TextField(String.localized("password.placeholder"), text: $viewModel.password)
                                        .textFieldStyle(LoginTextFieldStyle())
                                        .focused($focusedField, equals: .password)
                                        .submitLabel(.go)
                                        .onSubmit {
                                            if viewModel.isFormValid {
                                                viewModel.login()
                                            }
                                        }
                                } else {
                                    SecureField(String.localized("password.placeholder"), text: $viewModel.password)
                                        .textFieldStyle(LoginTextFieldStyle())
                                        .focused($focusedField, equals: .password)
                                        .submitLabel(.go)
                                        .onSubmit {
                                            if viewModel.isFormValid {
                                                viewModel.login()
                                            }
                                        }
                                }

                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        // Error message
                        if let key = viewModel.errorKey {
                            Text(String.localized(key))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.red)
                                .padding(.horizontal)
                                .transition(.opacity)
                        } else if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.red)
                                .padding(.horizontal)
                                .transition(.opacity)
                        }
                        
                        // Login button
                        Button(action: {
                            viewModel.login()
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text(verbatim: .localized("login.button.title"))
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(viewModel.isFormValid ? Color.black : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!viewModel.isFormValid)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.isFormValid)
                    }
                    .padding(.horizontal, 30)
                    Spacer()
                    HStack {
                        Button(String.localized("register.button.title")) {
                            
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button(String.localized("forgot.password.button.title")) {
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
                .background(Color.gray.opacity(0.05))
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.errorMessage)
    }
}

// MARK: - Custom TextField Style
struct LoginTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Diagonal Background (reused from splash screen)
struct DiagonalBackgroundView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.teal.opacity(0.3),
                            Color.teal.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .overlay(
                    DiagonalLinesPattern()
                        .opacity(0.2)
                )
                .clipShape(
                    TriangleShape()
                        .rotation(.degrees(45))
                )
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.2),
                            Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.1)
                        ],
                        startPoint: .center,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(
                    TriangleShape()
                        .rotation(.degrees(225))
                )
        }
    }
}

struct DiagonalLinesPattern: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let spacing: CGFloat = 8
                
                for i in stride(from: -width, through: width + height, by: spacing) {
                    path.move(to: CGPoint(x: i, y: 0))
                    path.addLine(to: CGPoint(x: i + height, y: height))
                }
            }
            .stroke(Color.white.opacity(0.2), lineWidth: 1)
        }
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}


// MARK: - Helper Functions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    LoginView()
}
