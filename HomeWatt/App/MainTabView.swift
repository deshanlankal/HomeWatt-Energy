//
//  MainTabView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-19.
//

import Foundation

import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: AppDestination = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: "house.fill", value: .dashboard) {
                DashboardView()
            }

            Tab("Devices", systemImage: "powerplug.fill", value: .devices) {
                DevicesView()
            }

            Tab("History", systemImage: "chart.bar.fill", value: .history) {
                HistoryView()
            }

            Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                SettingsView()
            }
        }
        .tint(HomeWattTheme.primary)
    }
}

#Preview {
    MainTabView()
}
