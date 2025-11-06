//
//  CustomerRegistrationViewModel.swift
//  customerRegistrationModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation
import SwiftUI

@MainActor
public final class CustomerRegistrationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var institutionName: String = ""
    @Published public var taxId: String = ""
    @Published public var address: String = ""
    @Published public var selectedCountry: Country?
    @Published public var mainContact: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var showSuccessAlert: Bool = false
    
    // MARK: - Private Properties
    private let service: CustomerRegistrationServiceProtocol
    private let token: String
    private let localizationHelper = CustomerRegistrationLocalizationHelper.shared
    
    // MARK: - Computed Properties
    public var isFormValid: Bool {
        !institutionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !taxId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedCountry != nil &&
        !mainContact.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Initialization
    public init(service: CustomerRegistrationServiceProtocol, token: String) {
        self.service = service
        self.token = token
    }
    
    // MARK: - Public Methods
    public func registerCustomer() async {
        guard isFormValid else {
            errorMessage = localizationHelper.localizedString(for: "customerregistration.error.validation.empty.fields")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let request = CustomerRegistrationRequest(
                institutionName: institutionName.trimmingCharacters(in: .whitespacesAndNewlines),
                taxId: taxId.trimmingCharacters(in: .whitespacesAndNewlines),
                address: address.trimmingCharacters(in: .whitespacesAndNewlines),
                country: selectedCountry?.id ?? "",
                mainContact: mainContact.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            _ = try await service.registerCustomer(request: request, token: token)
            
            // Show success and clear form
            showSuccessAlert = true
            clearForm()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    public func clearForm() {
        institutionName = ""
        taxId = ""
        address = ""
        selectedCountry = nil
        mainContact = ""
    }
    
    public func clearError() {
        errorMessage = nil
    }
}

