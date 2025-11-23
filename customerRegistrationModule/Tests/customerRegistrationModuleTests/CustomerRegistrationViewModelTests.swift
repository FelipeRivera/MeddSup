//
//  CustomerRegistrationViewModelTests.swift
//  customerRegistrationModuleTests
//
//  Created by Felipe Rivera on 3/09/25.
//

import Testing
@testable import customerRegistrationModule

@MainActor
struct CustomerRegistrationViewModelTests {
    
    // MARK: - Initialization Tests
    
    @Test func testInitialState() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        #expect(viewModel.institutionName == "")
        #expect(viewModel.taxId == "")
        #expect(viewModel.address == "")
        #expect(viewModel.selectedCountry == nil)
        #expect(viewModel.mainContact == "")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.showSuccessAlert == false)
        #expect(viewModel.institutionNameTouched == false)
        #expect(viewModel.taxIdTouched == false)
        #expect(viewModel.addressTouched == false)
        #expect(viewModel.countryTouched == false)
        #expect(viewModel.mainContactTouched == false)
    }
    
    // MARK: - Form Validation Tests
    
    @Test func testFormValidationWithAllEmptyFields() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.institutionName = ""
        viewModel.taxId = ""
        viewModel.address = ""
        viewModel.selectedCountry = nil
        viewModel.mainContact = ""
        
        #expect(viewModel.isFormValid == false)
    }
    
    @Test func testFormValidationWithAllFieldsFilled() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.institutionName = "Test Institution"
        viewModel.taxId = "123456789"
        viewModel.address = "123 Main St"
        viewModel.selectedCountry = Country.northAndSouthAmerica.first
        viewModel.mainContact = "John Doe"
        
        #expect(viewModel.isFormValid == true)
    }
    
    @Test func testFormValidationWithMissingInstitutionName() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.institutionName = ""
        viewModel.taxId = "123456789"
        viewModel.address = "123 Main St"
        viewModel.selectedCountry = Country.northAndSouthAmerica.first
        viewModel.mainContact = "John Doe"
        
        #expect(viewModel.isFormValid == false)
    }
    
    @Test func testFormValidationWithMissingTaxId() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.institutionName = "Test Institution"
        viewModel.taxId = ""
        viewModel.address = "123 Main St"
        viewModel.selectedCountry = Country.northAndSouthAmerica.first
        viewModel.mainContact = "John Doe"
        
        #expect(viewModel.isFormValid == false)
    }
    
    @Test func testFormValidationWithMissingAddress() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.institutionName = "Test Institution"
        viewModel.taxId = "123456789"
        viewModel.address = ""
        viewModel.selectedCountry = Country.northAndSouthAmerica.first
        viewModel.mainContact = "John Doe"
        
        #expect(viewModel.isFormValid == false)
    }
    
    @Test func testFormValidationWithMissingCountry() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.institutionName = "Test Institution"
        viewModel.taxId = "123456789"
        viewModel.address = "123 Main St"
        viewModel.selectedCountry = nil
        viewModel.mainContact = "John Doe"
        
        #expect(viewModel.isFormValid == false)
    }
    
    @Test func testFormValidationWithMissingMainContact() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.institutionName = "Test Institution"
        viewModel.taxId = "123456789"
        viewModel.address = "123 Main St"
        viewModel.selectedCountry = Country.northAndSouthAmerica.first
        viewModel.mainContact = ""
        
        #expect(viewModel.isFormValid == false)
    }
    
    @Test func testFormValidationWithWhitespaceOnlyFields() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.institutionName = "   "
        viewModel.taxId = "   "
        viewModel.address = "   "
        viewModel.selectedCountry = Country.northAndSouthAmerica.first
        viewModel.mainContact = "   "
        
        #expect(viewModel.isFormValid == false)
    }
    
    @Test func testFormValidationWithWhitespaceTrimmedFields() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.institutionName = "  Test Institution  "
        viewModel.taxId = "  123456789  "
        viewModel.address = "  123 Main St  "
        viewModel.selectedCountry = Country.northAndSouthAmerica.first
        viewModel.mainContact = "  John Doe  "
        
        #expect(viewModel.isFormValid == true)
    }
    
    // MARK: - Field Error Validation Tests
    
    @Test func testInstitutionNameErrorWhenNotTouched() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.institutionName = ""
        viewModel.institutionNameTouched = false
        
        #expect(viewModel.institutionNameError == nil)
    }
    
    @Test func testInstitutionNameErrorWhenTouchedAndEmpty() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.institutionName = ""
        viewModel.institutionNameTouched = true
        
        #expect(viewModel.institutionNameError != nil)
    }
    
    @Test func testInstitutionNameErrorWhenTouchedAndFilled() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.institutionName = "Test Institution"
        viewModel.institutionNameTouched = true
        
        #expect(viewModel.institutionNameError == nil)
    }
    
    @Test func testTaxIdErrorWhenNotTouched() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.taxId = ""
        viewModel.taxIdTouched = false
        
        #expect(viewModel.taxIdError == nil)
    }
    
    @Test func testTaxIdErrorWhenTouchedAndEmpty() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.taxId = ""
        viewModel.taxIdTouched = true
        
        #expect(viewModel.taxIdError != nil)
    }
    
    @Test func testAddressErrorWhenTouchedAndEmpty() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.address = ""
        viewModel.addressTouched = true
        
        #expect(viewModel.addressError != nil)
    }
    
    @Test func testCountryErrorWhenNotTouched() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.selectedCountry = nil
        viewModel.countryTouched = false
        
        #expect(viewModel.countryError == nil)
    }
    
    @Test func testCountryErrorWhenTouchedAndNotSelected() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.selectedCountry = nil
        viewModel.countryTouched = true
        
        #expect(viewModel.countryError != nil)
    }
    
    @Test func testCountryErrorWhenTouchedAndSelected() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.selectedCountry = Country.northAndSouthAmerica.first
        viewModel.countryTouched = true
        
        #expect(viewModel.countryError == nil)
    }
    
    @Test func testMainContactErrorWhenTouchedAndEmpty() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.mainContact = ""
        viewModel.mainContactTouched = true
        
        #expect(viewModel.mainContactError != nil)
    }
    
    @Test func testFieldErrorsWithWhitespaceOnly() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.institutionName = "   "
        viewModel.institutionNameTouched = true
        
        #expect(viewModel.institutionNameError != nil)
    }
    
    // MARK: - Clear Form Tests
    
    @Test func testClearForm() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        // Fill form
        viewModel.institutionName = "Test Institution"
        viewModel.taxId = "123456789"
        viewModel.address = "123 Main St"
        viewModel.selectedCountry = Country.northAndSouthAmerica.first
        viewModel.mainContact = "John Doe"
        
        // Mark fields as touched
        viewModel.institutionNameTouched = true
        viewModel.taxIdTouched = true
        viewModel.addressTouched = true
        viewModel.countryTouched = true
        viewModel.mainContactTouched = true
        
        // Clear form
        viewModel.clearForm()
        
        // Verify all fields are cleared
        #expect(viewModel.institutionName == "")
        #expect(viewModel.taxId == "")
        #expect(viewModel.address == "")
        #expect(viewModel.selectedCountry == nil)
        #expect(viewModel.mainContact == "")
        
        // Verify all touched states are reset
        #expect(viewModel.institutionNameTouched == false)
        #expect(viewModel.taxIdTouched == false)
        #expect(viewModel.addressTouched == false)
        #expect(viewModel.countryTouched == false)
        #expect(viewModel.mainContactTouched == false)
    }
    
    // MARK: - Clear Error Tests
    
    @Test func testClearError() {
        let mockService = MockCustomerRegistrationService()
        let viewModel = CustomerRegistrationViewModel(service: mockService, token: "test_token")
        
        viewModel.errorMessage = "Test error"
        
        viewModel.clearError()
        
        #expect(viewModel.errorMessage == nil)
    }
}

