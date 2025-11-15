//
//  VisitListView.swift
//  VisitLogModule
//
//  Created by GPT-5.1 Codex on 15/11/25.
//

import SwiftUI

public struct VisitListView: View {
    let visits: [Visit]
    let isSubmitting: Bool
    let onMove: (IndexSet, Int) -> Void
    let onDelete: (IndexSet) -> Void
    let onTap: (Visit) -> Void
    let onConfirm: () -> Void
    
    private let localization = VisitLogLocalizationHelper.shared
    
    public init(
        visits: [Visit],
        isSubmitting: Bool,
        onMove: @escaping (IndexSet, Int) -> Void,
        onDelete: @escaping (IndexSet) -> Void,
        onTap: @escaping (Visit) -> Void,
        onConfirm: @escaping () -> Void
    ) {
        self.visits = visits
        self.isSubmitting = isSubmitting
        self.onMove = onMove
        self.onDelete = onDelete
        self.onTap = onTap
        self.onConfirm = onConfirm
    }
    
    public var body: some View {
        Section(
            header: Text(localization.localizedString(for: "visitroute.planned.section.title"))
        ) {
            if visits.isEmpty {
                Text(localization.localizedString(for: "visitroute.planned.empty"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 16)
            } else {
                ForEach(visits) { visit in
                    Button {
                        onTap(visit)
                    } label: {
                        VisitRowView(visit: visit)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: onDelete)
                .onMove(perform: onMove)
                
                Button(action: onConfirm) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text(localization.localizedString(for: "visitroute.planned.button.confirm"))
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .listRowBackground(Color.clear)
                .disabled(isSubmitting)
            }
        }
    }
}

private struct VisitRowView: View {
    let visit: Visit
    private let localization = VisitLogLocalizationHelper.shared
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(localization.localizedString(
                    for: "visitroute.planned.row.title",
                    arguments: "\(visit.sequence)",
                    visit.client.name
                ))
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(visit.client.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(localization.localizedString(for: "visitroute.planned.row.time", arguments: visit.plannedHourText))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Image(systemName: visit.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(visit.isCompleted ? .green : .gray)
                if let timestamp = visit.completionTimestamp {
                    Text(timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 8)
    }
}


