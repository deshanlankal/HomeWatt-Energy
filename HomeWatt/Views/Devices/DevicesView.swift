
//
//  DevicesView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-19.
//

import Foundation
import SwiftUI

struct DevicesView: View {

    @Environment(HouseholdViewModel.self)
    private var householdViewModel

    @State private var applianceViewModel = ApplianceViewModel()
    @State private var showAddAppliance = false
    @State private var selectedAppliance: Appliance?

    private var householdId: String? {
        householdViewModel.household?.id
    }
    private var highEnergyThreshold: Double? { householdViewModel.household?.highEnergyThresholdWatts }

    var body: some View {
        NavigationStack {
            List {

                // MARK: - Active Power Summary

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Simulated Active Power")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        (
                            Text(
                                applianceViewModel.totalActivePowerWatts,
                                format: .number.precision(.fractionLength(0))
                            )
                            .font(.largeTitle.bold())
                            +
                            Text(" W")
                                .font(.title2)
                        )

                        Text(
                            "\(applianceViewModel.activeApplianceCount) appliances ON"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                // MARK: - Virtual Appliances

                Section("Virtual Appliances") {

                    if applianceViewModel.isLoading {

                        ProgressView("Loading appliances...")

                    } else if applianceViewModel.appliances.isEmpty {

                        ContentUnavailableView(
                            "No Appliances",
                            systemImage: "powerplug",
                            description: Text(
                                "Add your first virtual appliance to start simulating energy usage."
                            )
                        )

                    } else {

                        ForEach(applianceViewModel.appliances) { appliance in

                            HStack(spacing: 12) {

                                Image(
                                    systemName: appliance.category.symbolName
                                )
                                .font(.title2)
                                .foregroundStyle(HomeWattTheme.primary)
                                .frame(width: 40)

                                VStack(
                                    alignment: .leading,
                                    spacing: 4
                                ) {

                                    Text(appliance.name)
                                        .font(.headline)

                                    Text(
                                        "\(Int(appliance.ratedPowerWatts)) W · \(appliance.category.displayName)"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }

                                Spacer()

                                // Simulated ON/OFF switch

                                Toggle(
                                    "Power",
                                    isOn: Binding(
                                        get: {
                                            applianceViewModel.appliances
                                                .first(where: {
                                                    $0.id == appliance.id
                                                })?.isOn ?? appliance.isOn
                                        },
                                        set: { _ in
                                            Task {
                                                await applianceViewModel
                                                    .toggleAppliance(
                                                        appliance,
                                                        highEnergyThresholdWatts: highEnergyThreshold
                                                    )
                                            }
                                        }
                                    )
                                )
                                .labelsHidden()
                                .disabled(applianceViewModel.isSaving)
                            }
                            .padding(.vertical, 6)

                            // MARK: - Edit Appliance

                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedAppliance = appliance
                            }

                            // MARK: - Delete Appliance

                            
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task {
                                        await applianceViewModel.deleteAppliance(appliance, highEnergyThresholdWatts: highEnergyThreshold)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }

                        }
                    }
                }

                // MARK: - Error Message

                if let error = applianceViewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Devices")

            // MARK: - Add Appliance Button

            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddAppliance = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(householdId == nil)
                }
            }

            // MARK: - Add Appliance Sheet

            .sheet(isPresented: $showAddAppliance) {
                if let householdId {
                    AddApplianceView(
                        householdId: householdId,
                        highEnergyThresholdWatts: highEnergyThreshold,
                        applianceViewModel: applianceViewModel
                    )
                }
            }

            // MARK: - Edit Appliance Sheet

            .sheet(item: $selectedAppliance) { appliance in {
                EditApplianceView(
                    appliance: appliance,
                    applianceViewModel: applianceViewModel,
                    highEnergyThresholdWatts: highEnergyThreshold
                )
            }()

            }

            // MARK: - Load Appliances From Firebase

            .task(id: householdId) {
                applianceViewModel.reset()

                if let householdId {
                    await applianceViewModel.loadAppliances(
                        householdId: householdId
                    )
                }
            }
        }
    }
}
