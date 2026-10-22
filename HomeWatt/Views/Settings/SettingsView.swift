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

    // MARK: - Environment

    @Environment(AuthViewModel.self)
    private var authViewModel

    @Environment(HouseholdViewModel.self)
    private var householdViewModel

    // Local cache used by the Dashboard.
    @AppStorage("electricityRatePerKWh")
    private var electricityRatePerKWh = 30.0

    // MARK: - State

    @State private var rateInput = ""
    @State private var showSignOutConfirmation = false
    @State private var showRateSaved = false
    @State private var isSavingRate = false
    @State private var rateSaveError: String?

    // MARK: - Validation

    private var validRate: Double? {
        guard let rate = Double(
            rateInput.trimmingCharacters(in: .whitespacesAndNewlines)
        ),
        rate.isFinite,
        rate > 0,
        rate <= 1000 else {
            return nil
        }

        return rate
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Account

                Section("Account") {

                    if let email = authViewModel.currentUser?.email {
                        LabeledContent(
                            "Email",
                            value: email
                        )
                    }

                    LabeledContent(
                        "User ID",
                        value: authViewModel.currentUser?.uid ?? "Unknown"
                    )
                }

                // MARK: - Electricity Settings

                Section {

                    HStack {
                        Label(
                            "Rate per kWh",
                            systemImage: "bolt.fill"
                        )

                        Spacer()

                        TextField(
                            "30.00",
                            text: $rateInput
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 110)
                        .disabled(isSavingRate)

                        Text("LKR")
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent(
                        "Current Rate",
                        value: String(
                            format: "Rs. %.2f/kWh",
                            householdViewModel.household?
                                .electricityRatePerKWh
                                ?? electricityRatePerKWh
                        )
                    )

                    Button {
                        Task {
                            await saveElectricityRate()
                        }
                    } label: {
                        HStack(spacing: 10) {

                            if isSavingRate {
                                ProgressView()
                            } else {
                                Image(
                                    systemName: "square.and.arrow.down"
                                )
                            }

                            Text(
                                isSavingRate
                                    ? "Saving..."
                                    : "Save Electricity Rate"
                            )
                        }
                    }
                    .disabled(
                        validRate == nil ||
                        isSavingRate ||
                        householdViewModel.household == nil
                    )

                    if let rateSaveError {
                        Label(
                            rateSaveError,
                            systemImage: "exclamationmark.triangle"
                        )
                        .font(.footnote)
                        .foregroundStyle(.red)
                    }

                } header: {
                    Text("Electricity Settings")
                } footer: {
                    Text(
                        "This is a simplified flat electricity rate for simulated cost estimation. It does not represent official Sri Lankan electricity tariff slabs."
                    )
                }

                // MARK: - Security

                Section("Security") {

                    Button(role: .destructive) {
                        showSignOutConfirmation = true
                    } label: {
                        Label(
                            "Sign Out",
                            systemImage: "rectangle.portrait.and.arrow.right"
                        )
                    }
                }

                // MARK: - About

                Section("About") {

                    LabeledContent(
                        "Application",
                        value: "HomeWatt"
                    )

                    LabeledContent(
                        "Energy Data",
                        value: "Simulated"
                    )
                }
            }
            .navigationTitle("Settings")

            // MARK: - Load Saved Rate

            .onAppear {
                loadElectricityRate()
            }

            .onChange(
                of: householdViewModel.household?
                    .electricityRatePerKWh
            ) { _, _ in
                loadElectricityRate()
            }

            // MARK: - Save Confirmation

            .alert(
                "Electricity Rate Saved",
                isPresented: $showRateSaved
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(
                    "Your electricity rate has been saved to Firebase Firestore."
                )
            }

            // MARK: - Sign Out Confirmation

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

    // MARK: - Load Electricity Rate

    private func loadElectricityRate() {

        let savedRate = householdViewModel.household?
            .electricityRatePerKWh
            ?? electricityRatePerKWh

        rateInput = String(
            format: "%.2f",
            savedRate
        )
    }

    // MARK: - Save Electricity Rate to Firebase

    @MainActor
    private func saveElectricityRate() async {

        guard !isSavingRate else {
            return
        }

        guard let rate = validRate else {
            rateSaveError = "Please enter a valid electricity rate."
            return
        }

        guard householdViewModel.household != nil else {
            rateSaveError = "No household is currently available."
            return
        }

        isSavingRate = true
        rateSaveError = nil

        defer {
            isSavingRate = false
        }

        // Save the electricity rate to Firestore.
        let success = await householdViewModel
            .updateElectricityRate(rate)

        if success {

            // Update local cache for the Dashboard.
            electricityRatePerKWh = rate

            rateInput = String(
                format: "%.2f",
                rate
            )

            showRateSaved = true

        } else {

            rateSaveError = householdViewModel.errorMessage
                ?? "Unable to save the electricity rate."
        }
    }
}

