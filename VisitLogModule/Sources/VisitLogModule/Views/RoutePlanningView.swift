//
//  RoutePlanningView.swift
//  VisitLogModule
//
//  Created by GPT-5.1 Codex on 15/11/25.
//

import SwiftUI

public struct RoutePlanningView: View {
    @StateObject private var viewModel: VisitAgendaViewModel
    @State private var showClientSelector = false
    @State private var selectedVisit: Visit?
    
    private let localization = VisitLogLocalizationHelper.shared
    
    public init(viewModel: VisitAgendaViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            List {
                Section {
                    planCard
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                
                VisitListView(
                    visits: viewModel.plannedVisits,
                    isSubmitting: viewModel.isSubmitting,
                    onMove: viewModel.moveVisits,
                    onDelete: viewModel.deleteVisits,
                    onTap: { visit in
                        selectedVisit = visit
                    },
                    onConfirm: {
                        Task {
                            await viewModel.submitAgenda()
                        }
                    }
                )
                
                Section(
                    header: Text(localization.localizedString(for: "visitroute.report.section.title"))
                ) {
                    reportSection
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(localization.localizedString(for: "visitroute.title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showClientSelector) {
                ClientSelectionView(
                    clients: viewModel.availableClients,
                    preselected: viewModel.selectedClients,
                    onSelection: { clients in
                        viewModel.updateSelectedClients(clients)
                    }
                )
            }
            .sheet(item: $selectedVisit) { visit in
                NavigationView {
                    VisitDetailView(
                        viewModel: VisitDetailViewModel(visit: visit)
                    ) { updatedVisit in
                        viewModel.updateVisit(updatedVisit)
                    }
                }
            }
            .alert(
                localization.localizedString(for: "visitroute.alert.error.title"),
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { _ in viewModel.errorMessage = nil }
                ),
                actions: {
                    Button(localization.localizedString(for: "visitroute.button.ok"), role: .cancel) {
                        viewModel.errorMessage = nil
                    }
                },
                message: {
                    if let message = viewModel.errorMessage {
                        Text(message)
                    }
                }
            )
            .alert(
                localization.localizedString(for: "visitroute.alert.success.title"),
                isPresented: Binding(
                    get: { viewModel.successMessage != nil },
                    set: { _ in viewModel.successMessage = nil }
                ),
                actions: {
                    Button(localization.localizedString(for: "visitroute.button.ok"), role: .cancel) {
                        viewModel.successMessage = nil
                    }
                },
                message: {
                    if let message = viewModel.successMessage {
                        Text(message)
                    }
                }
            )
        }
    }
    
    private var planCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localization.localizedString(for: "visitroute.plan.section.title"))
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(localization.localizedString(for: "visitroute.plan.subtitle"))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(localization.localizedString(for: "visitroute.plan.field.date"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                DatePicker(
                    "",
                    selection: $viewModel.selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(localization.localizedString(for: "visitroute.plan.field.clients"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button {
                    showClientSelector = true
                } label: {
                    HStack {
                        Image(systemName: "person.3.fill")
                        Text(
                            viewModel.selectedClients.isEmpty
                            ? localization.localizedString(for: "visitroute.plan.clients.placeholder")
                            : localization.localizedString(
                                for: "visitroute.plan.clients.count",
                                arguments: "\(viewModel.selectedClients.count)"
                            )
                        )
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                if viewModel.selectedClients.isEmpty == false {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.selectedClients) { client in
                                Text(client.name)
                                    .font(.footnote)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
                            }
                        }
                    }
                }
            }
            
            Button {
                viewModel.generateAgenda()
            } label: {
                HStack {
                    if viewModel.isGenerating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(localization.localizedString(for: "visitroute.plan.button.generate"))
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .disabled(viewModel.selectedClients.isEmpty)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var reportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                radioButton(for: .byPeriod)
                radioButton(for: .byInstitution)
            }
            Button {
                // Placeholder action
            } label: {
                Text(localization.localizedString(for: "visitroute.report.button.view"))
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func radioButton(for filter: VisitAgendaViewModel.ReportFilter) -> some View {
        Button {
            viewModel.reportFilter = filter
        } label: {
            HStack {
                Image(systemName: viewModel.reportFilter == filter ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(.green)
                Text(localization.localizedString(for: filter.localizationKey))
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}


