//
//  ClientSelectionView.swift
//  VisitLogModule
//
//  Created by GPT-5.1 Codex on 15/11/25.
//

import SwiftUI

public struct ClientSelectionView: View {
    private let clients: [Client]
    private let onSelection: ([Client]) -> Void
    private let localization = VisitLogLocalizationHelper.shared
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText: String = ""
    @State private var selectedIDs: Set<Int>
    
    public init(
        clients: [Client],
        preselected: [Client],
        onSelection: @escaping ([Client]) -> Void
    ) {
        self.clients = clients
        self.onSelection = onSelection
        self._selectedIDs = State(initialValue: Set(preselected.map(\.id)))
    }
    
    public var body: some View {
        NavigationStack {
            List {
                ForEach(filteredClients) { client in
                    Button {
                        toggleSelection(for: client)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(client.name)
                                    .font(.headline)
                                Text(client.address)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if selectedIDs.contains(client.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .searchable(
                text: $searchText,
                prompt: localization.localizedString(for: "visitroute.client.selection.search")
            )
            .navigationTitle(localization.localizedString(for: "visitroute.client.selection.title"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.localizedString(for: "visitroute.client.selection.done")) {
                        confirmSelection()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.localizedString(for: "visitroute.client.selection.cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var filteredClients: [Client] {
        guard searchText.isEmpty == false else { return clients }
        return clients.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func toggleSelection(for client: Client) {
        if selectedIDs.contains(client.id) {
            selectedIDs.remove(client.id)
        } else {
            selectedIDs.insert(client.id)
        }
    }
    
    private func confirmSelection() {
        let selectedClients = clients.filter { selectedIDs.contains($0.id) }
        onSelection(selectedClients)
        dismiss()
    }
}


