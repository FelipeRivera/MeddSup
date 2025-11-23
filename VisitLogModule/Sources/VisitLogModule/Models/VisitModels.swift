//
//  VisitModels.swift
//  VisitLogModule
//
//  Created by GPT-5.1 Codex on 15/11/25.
//

import Foundation
import CoreLocation

/// Represents a commercial client that can be part of a visit plan.
public struct Client: Identifiable, Hashable, Codable {
    public let id: Int
    public var name: String
    public var address: String
    public var latitude: Double
    public var longitude: Double
    
    public init(
        id: Int,
        name: String,
        address: String,
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /// Returns the MapKit coordinate representation for the client.
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// Represents a single visit in the planning agenda.
public struct Visit: Identifiable, Hashable, Codable {
    public let id: UUID
    public var sequence: Int
    public var client: Client
    public var scheduledDate: Date
    public var plannedTime: Date
    public var isCompleted: Bool
    public var notes: String
    public var selectedTags: Set<VisitTag>
    public var attachments: [VisitAttachment]
    public var currentLatitude: Double?
    public var currentLongitude: Double?
    public var completionTimestamp: Date?
    
    public init(
        id: UUID = UUID(),
        sequence: Int,
        client: Client,
        scheduledDate: Date,
        plannedTime: Date,
        isCompleted: Bool = false,
        notes: String = "",
        selectedTags: Set<VisitTag> = [],
        attachments: [VisitAttachment] = [],
        currentLatitude: Double? = nil,
        currentLongitude: Double? = nil,
        completionTimestamp: Date? = nil
    ) {
        self.id = id
        self.sequence = sequence
        self.client = client
        self.scheduledDate = scheduledDate
        self.plannedTime = plannedTime
        self.isCompleted = isCompleted
        self.notes = notes
        self.selectedTags = selectedTags
        self.attachments = attachments
        self.currentLatitude = currentLatitude
        self.currentLongitude = currentLongitude
        self.completionTimestamp = completionTimestamp
    }
    
    /// Provides a formatted string for the planned hour.
    public var plannedHourText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: plannedTime)
    }
}

/// Represents the supported visit tags that describe the interaction type.
public enum VisitTag: String, CaseIterable, Codable, Identifiable {
    case installation
    case training
    case support
    case sales
    case other
    
    public var id: String { rawValue }
    
    /// Localization key for the tag label.
    public var localizationKey: String {
        switch self {
        case .installation: return "visitroute.detail.tags.installation"
        case .training: return "visitroute.detail.tags.training"
        case .support: return "visitroute.detail.tags.support"
        case .sales: return "visitroute.detail.tags.sales"
        case .other: return "visitroute.detail.tags.other"
        }
    }
}

/// Represents lightweight attachment metadata (placeholder for future media handling).
public struct VisitAttachment: Identifiable, Hashable, Codable {
    public enum AttachmentType: String, Codable {
        case photo
        case video
    }
    
    public let id: UUID
    public var type: AttachmentType
    public var fileName: String
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        type: AttachmentType,
        fileName: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.fileName = fileName
        self.createdAt = createdAt
    }
}

/// Payload structure to communicate with the remote visit API.
public struct VisitPayload: Codable, Sendable {
    public let visit_id: Int
    public let commercial_id: Int
    public let date: String
    public let client_ids: [Int]
    
    public init(
        visitID: Int,
        commercialID: Int,
        date: Date,
        clientIDs: [Int]
    ) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        self.visit_id = visitID
        self.commercial_id = commercialID
        self.date = formatter.string(from: date)
        self.client_ids = clientIDs
    }
}


