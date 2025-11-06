//
//  CustomerRegistrationModels.swift
//  customerRegistrationModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

// MARK: - Registration Request
public struct CustomerRegistrationRequest: Codable, Sendable {
    public let institutionName: String
    public let taxId: String
    public let address: String
    public let country: String
    public let mainContact: String
    
    enum CodingKeys: String, CodingKey {
        case institutionName = "institution_name"
        case taxId = "tax_id"
        case address
        case country
        case mainContact = "main_contact"
    }
    
    public init(
        institutionName: String,
        taxId: String,
        address: String,
        country: String,
        mainContact: String
    ) {
        self.institutionName = institutionName
        self.taxId = taxId
        self.address = address
        self.country = country
        self.mainContact = mainContact
    }
}

// MARK: - Registration Response
public struct CustomerRegistrationResponse: Codable, Sendable {
    public let success: Bool
    public let message: String?
    public let clientId: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case clientId = "client_id"
    }
}

// MARK: - Countries
public struct Country: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let nameES: String
    
    public init(id: String, name: String, nameES: String) {
        self.id = id
        self.name = name
        self.nameES = nameES
    }
    
    public static let northAndSouthAmerica: [Country] = [
        // North America
        Country(id: "US", name: "United States", nameES: "Estados Unidos"),
        Country(id: "CA", name: "Canada", nameES: "Canadá"),
        Country(id: "MX", name: "Mexico", nameES: "México"),
        Country(id: "GT", name: "Guatemala", nameES: "Guatemala"),
        Country(id: "BZ", name: "Belize", nameES: "Belice"),
        Country(id: "SV", name: "El Salvador", nameES: "El Salvador"),
        Country(id: "HN", name: "Honduras", nameES: "Honduras"),
        Country(id: "NI", name: "Nicaragua", nameES: "Nicaragua"),
        Country(id: "CR", name: "Costa Rica", nameES: "Costa Rica"),
        Country(id: "PA", name: "Panama", nameES: "Panamá"),
        // South America
        Country(id: "CO", name: "Colombia", nameES: "Colombia"),
        Country(id: "VE", name: "Venezuela", nameES: "Venezuela"),
        Country(id: "GY", name: "Guyana", nameES: "Guyana"),
        Country(id: "SR", name: "Suriname", nameES: "Surinam"),
        Country(id: "GF", name: "French Guiana", nameES: "Guayana Francesa"),
        Country(id: "BR", name: "Brazil", nameES: "Brasil"),
        Country(id: "EC", name: "Ecuador", nameES: "Ecuador"),
        Country(id: "PE", name: "Peru", nameES: "Perú"),
        Country(id: "BO", name: "Bolivia", nameES: "Bolivia"),
        Country(id: "PY", name: "Paraguay", nameES: "Paraguay"),
        Country(id: "UY", name: "Uruguay", nameES: "Uruguay"),
        Country(id: "AR", name: "Argentina", nameES: "Argentina"),
        Country(id: "CL", name: "Chile", nameES: "Chile"),
        Country(id: "FK", name: "Falkland Islands", nameES: "Islas Malvinas")
    ]
}

