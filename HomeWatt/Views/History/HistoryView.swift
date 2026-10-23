//
//  HistoryView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-19.
//

import Foundation
import SwiftUI
import Charts

struct HistoryView: View {

    @Environment(HouseholdViewModel.self)
    private var householdViewModel

    @State private var simulationViewModel =
        EnergySimulationViewModel()

    @State private var selectedDate = Date()

    private var householdId: String? {
        householdViewModel.household?.id
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Date Selection

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Date")
                            .font(.headline)

                        DatePicker(
                            "Energy Usage Date",
                            selection: $selectedDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                    }

                    Button {
                        guard let householdId else { return }

                        Task {
                            await simulationViewModel.generateDay(
                                householdId: householdId,
                                date: selectedDate
                            )
                        }
                    } label: {
                        HStack {
                            Spacer()

                            if simulationViewModel.isGenerating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "bolt.fill")
                                Text("Generate Simulated History")
                            }

                            Spacer()
                        }
                        .padding()
                        .foregroundStyle(.white)
                        .background(
                            HomeWattTheme.primary,
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                    }
                    .disabled(
                        householdId == nil ||
                        simulationViewModel.isGenerating
                    )
                    .accessibilityLabel(
                        simulationViewModel.isGenerating
                            ? "Generating simulated energy history"
                            : "Generate simulated energy history"
                    )
                    .accessibilityHint(
                        "Creates 30-minute simulated energy readings for the selected date."
                    )

                    if let success = simulationViewModel.successMessage {
                        Label(success, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.subheadline)
                    }

                    if let error = simulationViewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                            .font(.subheadline)
                    }

                    if simulationViewModel.isLoading {
                        ProgressView("Loading energy history...")
                            .frame(maxWidth: .infinity)
                    }

                    if !simulationViewModel.readings.isEmpty {

                        VStack(alignment: .leading, spacing: 16) {
                            Text("Daily Energy Summary")
                                .font(.title3.bold())

                            HStack(spacing: 12) {
                                summaryCard(
                                    title: "Energy",
                                    value: String(
                                        format: "%.2f kWh",
                                        simulationViewModel.totalEnergyKWh
                                    ),
                                    icon: "bolt.fill"
                                )

                                summaryCard(
                                    title: "Peak Power",
                                    value: String(
                                        format: "%.0f W",
                                        simulationViewModel.peakPowerWatts
                                    ),
                                    icon: "chart.line.uptrend.xyaxis"
                                )
                            }

                            summaryCard(
                                title: "Readings",
                                value: "\(simulationViewModel.readings.count) intervals",
                                icon: "clock"
                            )
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Electricity Consumption")
                                .font(.title3.bold())

                            Text("Simulated energy per 30-minute interval")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Chart(simulationViewModel.readings) { reading in
                                BarMark(
                                    x: .value(
                                        "Time",
                                        reading.intervalStart
                                    ),
                                    y: .value(
                                        "Energy (kWh)",
                                        reading.energyKWh
                                    )
                                )
                                .foregroundStyle(HomeWattTheme.primary)
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .hour, count: 4)) {
                                    AxisGridLine()
                                    AxisValueLabel(format: .dateTime.hour())
                                }
                            }
                            .frame(height: 250)
                        }
                        .padding()
                        .background(
                            Color(.secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(
                            "Electricity consumption chart. \(simulationViewModel.readings.count) simulated readings totaling \(String(format: "%.2f", simulationViewModel.totalEnergyKWh)) kilowatt-hours."
                        )

                    } else if !simulationViewModel.isLoading {

                        ContentUnavailableView(
                            "No Energy History",
                            systemImage: "chart.bar.xaxis",
                            description: Text(
                                "Generate simulated energy readings to view your household's electricity usage."
                            )
                        )
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Usage History")
            .task(id: historyLoadKey) {
                simulationViewModel.reset()

                if let householdId {
                    await simulationViewModel.loadReadings(
                        householdId: householdId,
                        date: selectedDate
                    )
                }
            }
        }
    }


    private var historyLoadKey: String {
        let dateKey = Calendar.current.startOfDay(
            for: selectedDate
        ).timeIntervalSince1970

        return "\(householdId ?? "")-\(dateKey)"
    }


    private func summaryCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(HomeWattTheme.primary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 14)
        )
    }
}

