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
    @EnvironmentObject private var notificationNavigation: NotificationNavigationState

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

            Tab("HomeKit", systemImage: "homekit", value: .homeKit) {
                HomeKitView()
            }

            Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                SettingsView()
            }
        }
        .tint(HomeWattTheme.primary)
        .onChange(of: notificationNavigation.requestedDestination) { _, destination in
            if let destination { selectedTab = destination; notificationNavigation.requestedDestination = nil }
        }
    }
}

#Preview {
    MainTabView()
}
