//
//  CustomerRegistrationView.swift
//  customerRegistrationModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI

public struct CustomerRegistrationView: View {
    @StateObject private var viewModel: CustomerRegistrationViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCountryPicker = false
    
    private let localizationHelper = CustomerRegistrationLocalizationHelper.shared
    
    public init(viewModel: CustomerRegistrationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            // Background
            Color.gray.opacity(0.05)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // White content card
                    VStack(spacing: 24) {
                        // Title
                        VStack(spacing: 4) {
                            Text(localizationHelper.localizedString(for: "customerregistration.title.line1"))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text(localizationHelper.localizedString(for: "customerregistration.title.line2"))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .padding(.top, 32)
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            // Institution Name
                            FormField(
                                label: localizationHelper.localizedString(for: "customerregistration.field.institution.name"),
                                placeholder: localizationHelper.localizedString(for: "customerregistration.placeholder.enter.name"),
                                text: $viewModel.institutionName
                            )
                            
                            // Tax ID
                            FormField(
                                label: localizationHelper.localizedString(for: "customerregistration.field.tax.id"),
                                placeholder: localizationHelper.localizedString(for: "customerregistration.placeholder.enter.identification"),
                                text: $viewModel.taxId
                            )
                            
                            // Address
                            FormField(
                                label: localizationHelper.localizedString(for: "customerregistration.field.address"),
                                placeholder: localizationHelper.localizedString(for: "customerregistration.placeholder.enter.address"),
                                text: $viewModel.address
                            )
                            
                            // Country Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text(localizationHelper.localizedString(for: "customerregistration.field.country"))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Button(action: {
                                    showCountryPicker = true
                                }) {
                                    HStack {
                                        Text(viewModel.selectedCountry == nil 
                                             ? localizationHelper.localizedString(for: "customerregistration.placeholder.enter.country")
                                             : getCountryName(for: viewModel.selectedCountry!))
                                            .font(.system(size: 16))
                                            .foregroundColor(viewModel.selectedCountry == nil ? .gray : .black)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                }
                            }
                            
                            // Main Contact
                            FormField(
                                label: localizationHelper.localizedString(for: "customerregistration.field.main.contact"),
                                placeholder: localizationHelper.localizedString(for: "customerregistration.placeholder.enter.main.contact"),
                                text: $viewModel.mainContact
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Register Button
                        Button(action: {
                            Task {
                                await viewModel.registerCustomer()
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text(localizationHelper.localizedString(for: "customerregistration.button.register"))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isFormValid && !viewModel.isLoading ? Color.green : Color.gray)
                        .cornerRadius(8)
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(localizationHelper.localizedString(for: "customerregistration.title.line1"))
                    .font(.system(size: 18, weight: .semibold))
            }
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(
                selectedCountry: $viewModel.selectedCountry,
                isPresented: $showCountryPicker
            )
        }
        .alert("", isPresented: $viewModel.showSuccessAlert) {
            Button(localizationHelper.localizedString(for: "customerregistration.button.ok")) {
                dismiss()
            }
        } message: {
            Text(localizationHelper.localizedString(for: "customerregistration.success.message"))
        }
        .alert(localizationHelper.localizedString(for: "customerregistration.error.title"), isPresented: .constant(viewModel.errorMessage != nil)) {
            Button(localizationHelper.localizedString(for: "customerregistration.button.ok")) {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func getCountryName(for country: Country) -> String {
        let isSpanish = localizationHelper.currentLanguage?.hasPrefix("es") ?? false
        return isSpanish ? country.nameES : country.name
    }
}

// MARK: - Form Field Component
private struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(8)
        }
    }
}

// MARK: - Country Picker View
private struct CountryPickerView: View {
    @Binding var selectedCountry: Country?
    @Binding var isPresented: Bool
    private let localizationHelper = CustomerRegistrationLocalizationHelper.shared
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Country.northAndSouthAmerica) { country in
                    Button(action: {
                        selectedCountry = country
                        isPresented = false
                    }) {
                        HStack {
                            Text(getCountryName(for: country))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            if selectedCountry?.id == country.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle(localizationHelper.localizedString(for: "customerregistration.field.country"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizationHelper.localizedString(for: "customerregistration.button.cancel")) {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func getCountryName(for country: Country) -> String {
        let isSpanish = localizationHelper.currentLanguage?.hasPrefix("es") ?? false
        return isSpanish ? country.nameES : country.name
    }
}

#Preview {
    NavigationView {
        CustomerRegistrationView(
            viewModel: CustomerRegistrationViewModel(
                service: CustomerRegistrationService(baseURL: "http://52.55.197.150/managers/api/v1/clients"),
                token: "mock_token"
            )
        )
    }
}

