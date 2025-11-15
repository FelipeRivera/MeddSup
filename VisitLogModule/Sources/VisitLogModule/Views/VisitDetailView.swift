//
//  VisitDetailView.swift
//  VisitLogModule
//
//  Created by GPT-5.1 Codex on 15/11/25.
//

import SwiftUI
import MapKit

public struct VisitDetailView: View {
    @StateObject private var viewModel: VisitDetailViewModel
    private let onSave: (Visit) -> Void
    private let localization = VisitLogLocalizationHelper.shared
    
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    
    public init(viewModel: VisitDetailViewModel, onSave: @escaping (Visit) -> Void) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onSave = onSave
        self._region = State(initialValue: VisitDetailView.createRegion(for: viewModel.visit.client))
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                visitHeader
                mapSection
                notesSection
                tagsSection
                evidenceSection
            }
            .padding()
        }
        .navigationTitle(localization.localizedString(for: "visitroute.detail.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(localization.localizedString(for: "visitroute.detail.button.done")) {
                    onSave(viewModel.visit)
                    dismiss()
                }
            }
        }
        .alert(
            localization.localizedString(for: "visitroute.error.location"),
            isPresented: $viewModel.showLocationError
        ) {
            Button(localization.localizedString(for: "visitroute.button.ok"), role: .cancel) {}
        }
        .onChange(of: viewModel.visit) { updated in
            onSave(updated)
        }
    }
    
    private var visitHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.visit.client.name)
                .font(.title2)
                .fontWeight(.bold)
            Text(viewModel.visit.client.address)
                .font(.body)
                .foregroundColor(.secondary)
            Text(localization.localizedString(for: "visitroute.detail.time", arguments: viewModel.visit.plannedHourText))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                viewModel.markVisitAsCompleted()
            }) {
                HStack {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(localization.localizedString(for: "visitroute.detail.button.mark"))
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.isSaving)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localization.localizedString(for: "visitroute.detail.map.title"))
                .font(.headline)
            Map(coordinateRegion: $region, annotationItems: [viewModel.visit.client]) { client in
                MapMarker(coordinate: client.coordinate, tint: .red)
            }
            .frame(height: 200)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localization.localizedString(for: "visitroute.detail.notes.title"))
                .font(.headline)
            TextEditor(text: Binding(
                get: { viewModel.visit.notes },
                set: { viewModel.visit.notes = $0 }
            ))
            .frame(minHeight: 120)
            .padding(8)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localization.localizedString(for: "visitroute.detail.tags.title"))
                .font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 8)], spacing: 8) {
                ForEach(VisitTag.allCases) { tag in
                    Button {
                        viewModel.toggleTag(tag)
                    } label: {
                        Text(localization.localizedString(for: tag.localizationKey))
                            .font(.footnote)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                viewModel.visit.selectedTags.contains(tag) ?
                                Color.green.opacity(0.2) :
                                Color.gray.opacity(0.1)
                            )
                            .foregroundColor(.primary)
                            .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var evidenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.localizedString(for: "visitroute.detail.evidence.title"))
                .font(.headline)
            
            HStack(spacing: 12) {
                Menu {
                    Button(localization.localizedString(for: "visitroute.detail.evidence.add.photo")) {
                        viewModel.addAttachment(type: .photo)
                    }
                    Button(localization.localizedString(for: "visitroute.detail.evidence.add.video")) {
                        viewModel.addAttachment(type: .video)
                    }
                } label: {
                    Label(
                        localization.localizedString(for: "visitroute.detail.evidence.add"),
                        systemImage: "plus.app.fill"
                    )
                    .font(.subheadline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.15))
                    .foregroundColor(.green)
                    .cornerRadius(12)
                }
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.visit.attachments) { attachment in
                    ZStack(alignment: .topTrailing) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 120)
                            .overlay(
                                VStack {
                                    Image(systemName: attachment.type == .photo ? "photo" : "video")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    Text(attachment.fileName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            )
                        Button {
                            viewModel.removeAttachment(attachment)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(6)
                        }
                    }
                }
            }
        }
    }
    
    private static func createRegion(for client: Client) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: client.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}


