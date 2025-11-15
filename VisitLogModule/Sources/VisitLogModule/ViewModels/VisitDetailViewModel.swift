//
//  VisitDetailViewModel.swift
//  VisitLogModule
//
//  Created by GPT-5.1 Codex on 15/11/25.
//

import Foundation
import Combine
import CoreLocation

/// Handles the state for a single visit detail, including location handling and evidence metadata.
@MainActor
public final class VisitDetailViewModel: NSObject, ObservableObject {
    @Published public var visit: Visit
    @Published public var isSaving: Bool = false
    @Published public var showLocationError: Bool = false
    
    private let locationManager = CLLocationManager()
    public override init() {
        self.visit = Visit(
            sequence: 1,
            client: Client(id: 0, name: "", address: "", latitude: 0, longitude: 0),
            scheduledDate: Date(),
            plannedTime: Date()
        )
        super.init()
        locationManager.delegate = self
    }
    
    public init(visit: Visit) {
        self.visit = visit
        super.init()
        locationManager.delegate = self
    }
    
    public func toggleTag(_ tag: VisitTag) {
        if visit.selectedTags.contains(tag) {
            visit.selectedTags.remove(tag)
        } else {
            visit.selectedTags.insert(tag)
        }
    }
    
    public func addAttachment(type: VisitAttachment.AttachmentType) {
        let placeholderName = type == .photo ? "evidence_photo.jpg" : "evidence_video.mov"
        let attachment = VisitAttachment(type: type, fileName: placeholderName)
        visit.attachments.append(attachment)
    }
    
    public func removeAttachment(_ attachment: VisitAttachment) {
        visit.attachments.removeAll(where: { $0.id == attachment.id })
    }
    
    /// Marks the visit as completed, collecting location data when available.
    public func markVisitAsCompleted() {
        isSaving = true
        requestLocation()
    }
    
    private func requestLocation() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            showLocationError = true
            finalizeCompletion(latitude: nil, longitude: nil)
        }
    }
    
    private func finalizeCompletion(latitude: Double?, longitude: Double?) {
        visit.isCompleted = true
        visit.currentLatitude = latitude ?? visit.currentLatitude
        visit.currentLongitude = longitude ?? visit.currentLongitude
        visit.completionTimestamp = Date()
        isSaving = false
    }
}

extension VisitDetailViewModel: CLLocationManagerDelegate {
    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            manager.requestLocation()
        } else if manager.authorizationStatus == .denied {
            Task { @MainActor in
                showLocationError = true
                finalizeCompletion(latitude: nil, longitude: nil)
            }
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else {
            Task { @MainActor in
                finalizeCompletion(latitude: nil, longitude: nil)
            }
            return
        }
        Task { @MainActor in
            finalizeCompletion(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            showLocationError = true
            finalizeCompletion(latitude: nil, longitude: nil)
        }
    }
}
