//
//  HouseholdOnboardingView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-21.
//

import Foundation

import SwiftUI

struct HouseholdOnboardingView: View {

    let householdViewModel: HouseholdViewModel

    @State private var householdName = "My Home"
    @State private var householdType: HouseholdType = .house
    @State private var residents = 4
    @State private var monthlyBudget = 10000.0
    @State private var highEnergyThreshold = 3000.0

    var body: some View {
        NavigationStack {
            Form {

                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 54))
                            .foregroundStyle(.green)

                        Text("Set Up Your Home")
                            .font(.title2.bold())

                        Text("Create a virtual household to simulate and monitor electricity usage.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }

                Section("Household Details") {
                    TextField("Household Name", text: $householdName)

                    Picker("Home Type", selection: $householdType) {
                        ForEach(HouseholdType.allCases) { type in
                            Text(type.displayName)
                                .tag(type)
                        }
                    }

                    Stepper(
                        "Residents: \(residents)",
                        value: $residents,
                        in: 1...20
                    )
                }

                Section {
                    LabeledContent("Monthly Budget") {
                        TextField(
                            "Budget",
                            value: $monthlyBudget,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("High Energy Threshold") {
                        TextField(
                            "Threshold",
                            value: $highEnergyThreshold,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }

                } header: {
                    Text("Energy Preferences")
                } footer: {
                    Text("Budget is in LKR per month. The high energy threshold is measured in watts (W) and will be used for simulated high-power alerts.")
                }

                if let error = householdViewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }

                Section {
                    Button {
                        Task {
                            await householdViewModel.createHousehold(
                                name: householdName,
                                type: householdType,
                                residents: residents,
                                monthlyBudgetLKR: monthlyBudget,
                                highEnergyThresholdWatts: highEnergyThreshold
                            )
                        }
                    } label: {
                        HStack {
                            Spacer()

                            if householdViewModel.isSaving {
                                ProgressView()
                            } else {
                                Label(
                                    "Create Household",
                                    systemImage: "checkmark.circle.fill"
                                )
                            }

                            Spacer()
                        }
                    }
                    .disabled(
                        householdViewModel.isSaving ||
                        householdName.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty ||
                        !monthlyBudget.isFinite ||
                        monthlyBudget <= 0 ||
                        !highEnergyThreshold.isFinite ||
                        highEnergyThreshold <= 0
                    )
                }

            }
            .navigationTitle("Home Setup")
        }
    }
}
