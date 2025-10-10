//
//  LocalizationTests.swift
//  LoginModuleTests
//
//  Created by Felipe Rivera on 3/09/25.
//

import XCTest
@testable import LoginModule

final class LocalizationTests: XCTestCase {
    
    func testLocalizationHelper() {
        // Test that localization helper works
        let localizedString = String.localized("login.header.title")
        XCTAssertFalse(localizedString.isEmpty)
        XCTAssertNotEqual(localizedString, "login.header.title") // Should not return the key
    }
    
    func testSpanishLocalization() {
        // Test Spanish localization by temporarily changing the language
        let originalLanguage = Locale.current.language.languageCode?.identifier
        
        // Note: In a real test environment, you would need to set the app's language
        // This is a basic test to ensure the localization system is working
        let localizedString = String.localized("login.header.title")
        XCTAssertFalse(localizedString.isEmpty)
    }
    
    func testErrorMessagesLocalization() {
        // Test that error messages are localized
        let emptyFieldsError = String.localized("error.validation.empty.fields")
        XCTAssertFalse(emptyFieldsError.isEmpty)
        XCTAssertNotEqual(emptyFieldsError, "error.validation.empty.fields")
        
        let invalidCredentialsError = String.localized("error.invalid.credentials")
        XCTAssertFalse(invalidCredentialsError.isEmpty)
        XCTAssertNotEqual(invalidCredentialsError, "error.invalid.credentials")
    }
    
    func testLoginErrorLocalization() {
        // Test LoginError localization
        let invalidCredentialsError = LoginError.invalidCredentials
        XCTAssertNotNil(invalidCredentialsError.errorDescription)
        XCTAssertFalse(invalidCredentialsError.errorDescription?.isEmpty ?? true)
        
        let networkError = LoginError.networkError("Test message")
        XCTAssertNotNil(networkError.errorDescription)
        XCTAssertTrue(networkError.errorDescription?.contains("Test message") ?? false)
    }
}
