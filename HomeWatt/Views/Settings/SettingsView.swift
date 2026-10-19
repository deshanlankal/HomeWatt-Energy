//
//  SettingsView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-19.
//

import Foundation

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Settings",
                systemImage: "gearshape.fill",
                description: Text("Manage your profile, household, and preferences.")
            )
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
