//
//  EditApplianceView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-21.
//

import Foundation

import SwiftUI

struct EditApplianceView: View {

    let appliance: Appliance
    let applianceViewModel: ApplianceViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var category: ApplianceCategory
    @State private var ratedPowerWatts: Double
    @State private var estimatedHoursPerDay: Double

    init(
        appliance: Appliance,
        applianceViewModel: ApplianceViewModel
    ) {
        self.appliance = appliance
        self.applianceViewModel = applianceViewModel

        _name = State(initialValue: appliance.name)
        _category = State(initialValue: appliance.category)
        _ratedPowerWatts = State(initialValue: appliance.ratedPowerWatts)
        _estimatedHoursPerDay = State(
            initialValue: appliance.estimatedHoursPerDay
        )
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        ratedPowerWatts.isFinite &&
        ratedPowerWatts > 0 &&
        estimatedHoursPerDay.isFinite &&
        (0...24).contains(estimatedHoursPerDay)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Appliance Details") {
                    TextField("Name", text: $name)

                    Picker("Category", selection: $category) {
                        ForEach(ApplianceCategory.allCases) { item in
                            Text(item.displayName)
                                .tag(item)
                        }
                    }
                }

                Section("Simulation Settings") {
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
                            var updated = appliance
                            updated.name = name.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            updated.category = category
                            updated.ratedPowerWatts = ratedPowerWatts
                            updated.estimatedHoursPerDay = estimatedHoursPerDay

                            let success = await applianceViewModel
                                .updateAppliance(updated)

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
                                Text("Save Changes")
                                    .fontWeight(.semibold)
                            }

                            Spacer()
                        }
                    }
                    .disabled(!isValid || applianceViewModel.isSaving)
                }

                if let error = applianceViewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Edit Appliance")
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
