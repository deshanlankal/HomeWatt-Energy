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

    @Environment(HouseholdViewModel.self)
    private var householdViewModel

    // Local cache for the electricity rate.
    // The household model in Firebase is the source of truth.
    @AppStorage("electricityRatePerKWh")
    private var electricityRatePerKWh = 30.0

    // User preference for high-energy alerts.
    @AppStorage("homewatt.highEnergyAlertsEnabled")
    private var highEnergyAlertsEnabled = true

    // New biometric lock setting
    @AppStorage("homewatt.biometricLockEnabled")
    private var biometricLockEnabled = false

    @State private var notificationsEnabled = false

    @State private var rateInput = ""
    @State private var thresholdInput = ""
    @State private var showSignOutConfirmation = false
    @State private var showRateSaved = false
    @State private var showThresholdSaved = false
    @State private var isSavingRate = false
    @State private var isSavingThreshold = false
    @State private var rateSaveError: String?
    @State private var thresholdSaveError: String?

    private var validRate: Double? {

        guard let rate = Double(
            rateInput.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        ),
        rate.isFinite,
        rate > 0,
        rate <= 1000 else {
            return nil
        }

        return rate
    }

    private var validThreshold: Double? {

        guard let threshold = Double(
            thresholdInput.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        ),
        threshold.isFinite,
        threshold > 0,
        threshold <= 100_000 else {
            return nil
        }

        return threshold
    }

    var body: some View {

        NavigationStack {

            Form {

                Section {

                    // iOS Notification Permission Status

                    HStack {

                        Label(
                            "Notification Permission",
                            systemImage: "bell.badge"
                        )

                        Spacer()

                        Text(
                            notificationsEnabled
                                ? "Enabled"
                                : "Disabled"
                        )
                        .foregroundStyle(
                            notificationsEnabled
                                ? HomeWattTheme.primary
                                : Color.secondary
                        )
                    }

                    // High Energy Alerts Toggle

                    Toggle(
                        isOn: $highEnergyAlertsEnabled
                    ) {

                        Label(
                            "High Energy Alerts",
                            systemImage: "bolt.badge.clock"
                        )
                    }
                    .tint(HomeWattTheme.primary)
                    .onChange(of: highEnergyAlertsEnabled) { _, enabled in
                        Task { await PushNotificationService.shared.updateHighEnergyPreference(enabled: enabled) }
                    }

                    // Enable Notification Permission

                    if !notificationsEnabled {

                        Button {

                            Task {
                                await enableNotifications()
                            }

                        } label: {

                            Label(
                                "Enable Notifications",
                                systemImage: "bell"
                            )
                        }
                    }

                } header: {

                    Text("Notifications")

                } footer: {

                    Text(
                        "Turn High Energy Alerts on or off. HomeWatt sends local notifications when simulated active power exceeds your household threshold. iOS notification permission is also required."
                    )
                }


                Section("Account") {

                    if let email = authViewModel.currentUser?.email {

                        LabeledContent(
                            "Email",
                            value: email
                        )
                    }

                    LabeledContent(
                        "User ID",
                        value: authViewModel.currentUser?.uid
                            ?? "Unknown"
                    )
                }


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

                    // Current Firebase Rate

                    LabeledContent(
                        "Current Rate",
                        value: String(
                            format: "Rs. %.2f/kWh",
                            householdViewModel.household?
                                .electricityRatePerKWh
                                ?? electricityRatePerKWh
                        )
                    )

                    Divider()

                    HStack {

                        Label(
                            "High-Energy Threshold",
                            systemImage: "gauge.with.dots.needle.50percent"
                        )

                        Spacer()

                        TextField(
                            "3000",
                            text: $thresholdInput
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 110)
                        .disabled(isSavingThreshold)

                        Text("W")
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent(
                        "Current Threshold",
                        value: String(
                            format: "%.0f W",
                            householdViewModel.household?
                                .highEnergyThresholdWatts
                                ?? 0
                        )
                    )

                    // Save Rate Button

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

                    Button {

                        Task {
                            await saveHighEnergyThreshold()
                        }

                    } label: {

                        HStack(spacing: 10) {

                            if isSavingThreshold {

                                ProgressView()

                            } else {

                                Image(
                                    systemName: "bell.badge"
                                )
                            }

                            Text(
                                isSavingThreshold
                                    ? "Saving..."
                                    : "Save High-Energy Threshold"
                            )
                        }
                    }
                    .disabled(
                        validThreshold == nil ||
                        isSavingThreshold ||
                        householdViewModel.household == nil
                    )

                    // Rate Save Error

                    if let rateSaveError {

                        Label(
                            rateSaveError,
                            systemImage: "exclamationmark.triangle"
                        )
                        .font(.footnote)
                        .foregroundStyle(.red)
                    }

                    if let thresholdSaveError {

                        Label(
                            thresholdSaveError,
                            systemImage: "exclamationmark.triangle"
                        )
                        .font(.footnote)
                        .foregroundStyle(.red)
                    }

                } header: {

                    Text("Electricity Settings")

                } footer: {

                    Text(
                        "The electricity rate is used only for simulated cost estimates. The high-energy threshold is measured in watts (W); set it to 10 W for a quick notification test."
                    )
                }

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


                Section("Security & Biometrics") {
                    Toggle(isOn: Binding(get: { biometricLockEnabled }, set: { enabled in
                        Task {
                            if enabled {
                                if await BiometricLockManager.shared.enableAfterVerification() { biometricLockEnabled = true }
                            } else { biometricLockEnabled = false; BiometricLockManager.shared.biometricLockEnabled = false }
                        }
                    })) {
                        Label("Require Face ID / Touch ID to Unlock", systemImage: "faceid")
                    }
                    .tint(HomeWattTheme.primary)
                    .accessibilityLabel("Require biometric authentication")
                    .accessibilityHint("Enable Face ID or Touch ID to unlock the app on launch or resume.")
                }

                LiveActivityControlView()

                //////////////

                #if DEBUG
                Section("Developer Diagnostics") {

                    Button {
                        SentryDiagnostics.sendTestEvent()
                    } label: {
                        Label(
                            "Send Sentry Test Event",
                            systemImage: "ladybug.fill"
                        )
                    }
                    .tint(HomeWattTheme.primary)

                    Text(
                        "Send a test diagnostic event to verify the Sentry SDK integration."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                #endif

                //////////////

                Section("About") {

                    LabeledContent(
                        "Application",
                        value: "HomeWatt"
                    )

                    LabeledContent(
                        "Energy Data",
                        value: "Simulated"
                    )

                    LabeledContent(
                        "High Energy Detection",
                        value: "Supported"
                    )

                    LabeledContent(
                        "Notifications",
                        value: "Local + FCM remote"
                    )
                }
            }
            .navigationTitle("Settings")


            .onAppear {

                loadElectricityRate()
                loadHighEnergyThreshold()
                BiometricLockManager.shared.biometricLockEnabled = biometricLockEnabled
                Task { await refreshNotificationStatus() }
            }


            .onChange(
                of: householdViewModel.household?
                    .electricityRatePerKWh
            ) { _, _ in

                loadElectricityRate()
            }

            .onChange(
                of: householdViewModel.household?
                    .highEnergyThresholdWatts
            ) { _, _ in

                loadHighEnergyThreshold()
            }


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

            .alert(
                "High-Energy Threshold Saved",
                isPresented: $showThresholdSaved
            ) {

                Button("OK", role: .cancel) {}

            } message: {

                Text(
                    "Your high-energy alert threshold has been saved to Firebase Firestore."
                )
            }


            .alert(
                "Sign Out",
                isPresented: $showSignOutConfirmation
            ) {

                Button(
                    "Cancel",
                    role: .cancel
                ) {}

                Button(
                    "Sign Out",
                    role: .destructive
                ) {
                    Task {
                        await authViewModel.logout()
                    }
                }

            } message: {

                Text(
                    "Are you sure you want to sign out of HomeWatt?"
                )
            }
        }
    }


    private func loadElectricityRate() {

        let savedRate = householdViewModel.household?
            .electricityRatePerKWh
            ?? electricityRatePerKWh

        rateInput = String(
            format: "%.2f",
            savedRate
        )
    }

    private func loadHighEnergyThreshold() {

        guard let threshold = householdViewModel.household?
            .highEnergyThresholdWatts else {
            thresholdInput = ""
            return
        }

        thresholdInput = String(
            format: "%.0f",
            threshold
        )
    }


    @MainActor
    private func saveElectricityRate() async {

        guard !isSavingRate else {
            return
        }

        guard let rate = validRate else {

            rateSaveError =
                "Please enter a valid electricity rate."

            return
        }

        guard householdViewModel.household != nil else {

            rateSaveError =
                "No household is currently available."

            return
        }

        isSavingRate = true
        rateSaveError = nil

        defer {
            isSavingRate = false
        }

        let success = await householdViewModel
            .updateElectricityRate(rate)

        if success {

            // Update the local cache after Firebase saves.
            electricityRatePerKWh = rate

            rateInput = String(
                format: "%.2f",
                rate
            )

            showRateSaved = true

        } else {

            rateSaveError =
                householdViewModel.errorMessage
                ?? "Unable to save the electricity rate."
        }
    }

    @MainActor
    private func saveHighEnergyThreshold() async {

        guard !isSavingThreshold else {
            return
        }

        guard let threshold = validThreshold else {

            thresholdSaveError =
                "Enter a threshold between 1 W and 100,000 W."

            return
        }

        guard householdViewModel.household != nil else {

            thresholdSaveError =
                "No household is currently available."

            return
        }

        isSavingThreshold = true
        thresholdSaveError = nil

        defer {
            isSavingThreshold = false
        }

        let success = await householdViewModel
            .updateHighEnergyThreshold(threshold)

        if success {

            thresholdInput = String(
                format: "%.0f",
                threshold
            )

            showThresholdSaved = true

        } else {

            thresholdSaveError =
                householdViewModel.errorMessage
                ?? "Unable to save the high-energy threshold."
        }
    }


    @MainActor
    private func refreshNotificationStatus() async {

        notificationsEnabled =
            await NotificationService.shared
                .notificationsEnabled()
    }


    @MainActor
    private func enableNotifications() async {

        _ = await NotificationService.shared
            .requestPermission()

        await refreshNotificationStatus()
    }
}
