//
//  VisitLogModule.swift
//  VisitLogModule
//
//  Created by GPT-5.1 Codex on 15/11/25.
//

import SwiftUI

@MainActor
public enum VisitLogModule {
    /// Provides the entry point for the Route Planning experience embedded in the MeddSup app.
    public static func createRoutePlanningView(
        baseURL: String,
        commercialId: Int
    ) -> some View {
        let service = VisitService(baseURL: baseURL)
        let viewModel = VisitAgendaViewModel(
            service: service,
            commercialId: commercialId,
            availableClients: []
        )
        return RoutePlanningView(viewModel: viewModel)
    }
}

