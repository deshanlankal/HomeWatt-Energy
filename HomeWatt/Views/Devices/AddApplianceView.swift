//
//  AddApplianceView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-21.
//

import Foundation

import SwiftUI

struct AddApplianceView: View {

    let householdId: String
    let applianceViewModel: ApplianceViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category: ApplianceCategory = .fan
    @State private var ratedPowerWatts = 75.0
    @State private var estimatedHoursPerDay = 4.0

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Appliance Details")) {
                    TextField("Appliance Name", text: $name)

                    Picker("Category", selection: $category) {
                        ForEach(ApplianceCategory.allCases) { item in
                            Text(item.displayName)
                                .tag(item)
                        }
                    }
                }

                Section(header: Text("Simulation Settings"), footer: Text(
                    "These values are simulation assumptions, not measurements from real appliances."
                )) {
                    LabeledContent("Rated Power (W)") {
                        TextField(
                            "Watts",
                            value: $ratedPowerWatts,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("Estimated Hours/Day") {
                        TextField(
                            "Hours",
                            value: $estimatedHoursPerDay,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }
                }

                Section {
                    Button {
                        Task {
                            let success = await applianceViewModel.addAppliance(
                                householdId: householdId,
                                name: name,
                                category: category,
                                ratedPowerWatts: ratedPowerWatts,
                                estimatedHoursPerDay: estimatedHoursPerDay
                            )

                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()

                            if applianceViewModel.isSaving {
                                ProgressView()
                            } else {
                                Text("Add Appliance")
                                    .fontWeight(.semibold)
                            }

                            Spacer()
                        }
                    }
                    .disabled(
                        applianceViewModel.isSaving ||
                        name.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty ||
                        !ratedPowerWatts.isFinite ||
                        ratedPowerWatts <= 0 ||
                        !estimatedHoursPerDay.isFinite ||
                        !(0...24).contains(estimatedHoursPerDay)
                    )
                }

                if let error = applianceViewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Appliance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
