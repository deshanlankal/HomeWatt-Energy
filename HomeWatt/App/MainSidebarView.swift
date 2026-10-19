//
//  MainSidebarView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-19.
//

import Foundation

import SwiftUI

struct MainSidebarView: View {

    @State private var selectedDestination: AppDestination? = .dashboard

    var body: some View {
        NavigationSplitView {
            List(
                AppDestination.allCases,
                selection: $selectedDestination
            ) { destination in
                Label(destination.title, systemImage: destination.symbol)
                    .tag(destination)
            }
            .navigationTitle("HomeWatt")
        } detail: {
            Group {
                switch selectedDestination ?? .dashboard {
                case .dashboard:
                    DashboardView()
                case .devices:
                    DevicesView()
                case .history:
                    HistoryView()
                case .settings:
                    SettingsView()
                }
            }
        }
        .tint(HomeWattTheme.primary)
    }
}

#Preview {
    MainSidebarView()
}
