//
//  DevicesView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-19.
//

import Foundation

import SwiftUI

struct DevicesView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Devices",
                systemImage: "powerplug",
                description: Text("Manage your virtual appliances and Apple Home devices.")
            )
            .navigationTitle("Devices")
        }
    }
}

#Preview {
    DevicesView()
}
    