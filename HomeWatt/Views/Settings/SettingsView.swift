//
//  SettingsView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-19.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct SettingsView: View {

    @Environment(AuthViewModel.self)
    private var authViewModel

    @State private var showSignOutConfirmation = false

    var body: some View {
        NavigationStack {
            Form {

                Section("Account") {
                    if let email = authViewModel.currentUser?.email {
                        LabeledContent("Email", value: email)
                    }

                    LabeledContent(
                        "User ID",
                        value: authViewModel.currentUser?.uid ?? "Unknown"
                    )
                }

                Section("Security") {
                    Button(role: .destructive) {
                        showSignOutConfirmation = true
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }

                Section("About") {
                    LabeledContent("Application", value: "HomeWatt")
                    LabeledContent("Energy Data", value: "Simulated")
                }
            }
            .navigationTitle("Settings")
            .alert(
                "Sign Out",
                isPresented: $showSignOutConfirmation
            ) {
                Button("Cancel", role: .cancel) {}

                Button("Sign Out", role: .destructive) {
                    authViewModel.logout()
                }
            } message: {
                Text("Are you sure you want to sign out of HomeWatt?")
            }
        }
    }
}
