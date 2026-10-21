
//
//  DashboardView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-19.
//

import Foundation
import SwiftUI
import Charts

struct DashboardView: View {

    @Environment(HouseholdViewModel.self)
    private var householdViewModel

    @State private var applianceViewModel = ApplianceViewModel()
    @State private var simulationViewModel = EnergySimulationViewModel()

    private var householdId: String? {
        householdViewModel.household?.id
    }

    private var energySummary: EnergySimulationSummary {
        EnergySimulationService.estimate(
            appliances: applianceViewModel.appliances
        )
    }
    
    private var monthlyCostEstimate: ElectricityCostEstimate {
        ElectricityCostService.monthlyEstimate(
            appliances: applianceViewModel.appliances
        )
    }


    private var todayEnergyKWh: Double {
        simulationViewModel.totalEnergyKWh
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Header

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Energy Overview")
                            .font(.title2.bold())

                        Text("Your household's simulated electricity usage")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // MARK: - Statistics

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {

                        statisticCard(
                            title: "Today's Energy",
                            value: String(
                                format: "%.2f",
                                todayEnergyKWh
                            ),
                            unit: "kWh",
                            icon: "bolt.fill"
                        )

                        statisticCard(
                            title: "Active Power",
                            value: String(
                                format: "%.0f",
                                applianceViewModel.totalActivePowerWatts
                            ),
                            unit: "W",
                            icon: "power"
                        )

                        statisticCard(
                            title: "Peak Demand",
                            value: String(
                                format: "%.0f",
                                simulationViewModel.peakPowerWatts
                            ),
                            unit: "W",
                            icon: "chart.line.uptrend.xyaxis"
                        )

                        statisticCard(
                            title: "Monthly Estimate",
                            value: String(
                                format: "%.1f",
                                energySummary.monthlyEnergyKWh
                            ),
                            unit: "kWh",
                            icon: "calendar"
                        )
                    }

                    
                    // MARK: - Estimated Electricity Bill

                    VStack(alignment: .leading, spacing: 12) {

                        Label(
                            "Estimated Monthly Electricity Bill",
                            systemImage: "creditcard"
                        )
                        .font(.headline)

                        Text(
                            ElectricityCostService.formatLKR(
                                monthlyCostEstimate.totalCostLKR
                            )
                        )
                        .font(.largeTitle.bold())
                        .foregroundStyle(HomeWattTheme.primary)

                        Text(
                            String(
                                format: "%.1f kWh × Rs. %.2f/kWh",
                                monthlyCostEstimate.energyKWh,
                                monthlyCostEstimate.ratePerKWh
                            )
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                        Divider()

                        Label(
                            "This is a simulated flat-rate estimate, not an official electricity bill.",
                            systemImage: "info.circle"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 16)
                    )

                    // MARK: - Energy Chart

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Energy Usage")
                            .font(.headline)

                        Text("Simulated consumption per 30-minute interval")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if simulationViewModel.readings.isEmpty {

                            ContentUnavailableView(
                                "No Readings Yet",
                                systemImage: "chart.bar.xaxis",
                                description: Text(
                                    "Generate today's simulated readings in the History tab to display the chart."
                                )
                            )

                        } else {

                            Chart(simulationViewModel.readings) { reading in
                                BarMark(
                                    x: .value(
                                        "Time",
                                        reading.intervalStart
                                    ),
                                    y: .value(
                                        "Energy",
                                        reading.energyKWh
                                    )
                                )
                                .foregroundStyle(HomeWattTheme.primary)
                            }
                            .chartXAxis {
                                AxisMarks(
                                    values: .stride(
                                        by: .hour,
                                        count: 4
                                    )
                                ) {
                                    AxisGridLine()
                                    AxisValueLabel(
                                        format: .dateTime.hour()
                                    )
                                }
                            }
                            .frame(height: 240)
                        }
                    }
                    .padding()
                    .background(
                        Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 16)
                    )

                    // MARK: - Appliance Summary

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Appliance Summary")
                            .font(.headline)

                        HStack {
                            Label(
                                "Total Appliances",
                                systemImage: "powerplug"
                            )

                            Spacer()

                            Text(
                                "\(applianceViewModel.appliances.count)"
                            )
                            .fontWeight(.semibold)
                        }

                        Divider()

                        HStack {
                            Label(
                                "Currently ON",
                                systemImage: "power"
                            )

                            Spacer()

                            Text(
                                "\(applianceViewModel.activeApplianceCount)"
                            )
                            .fontWeight(.semibold)
                            .foregroundStyle(HomeWattTheme.primary)
                        }
                    }
                    .padding()
                    .background(
                        Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 16)
                    )

                    // MARK: - Simulation Information

                    Label(
                        "All energy values are simulated estimates, not live smart-meter readings.",
                        systemImage: "info.circle"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    // MARK: - Errors

                    if let error = applianceViewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }

                    if let error = simulationViewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")

            // MARK: - Refresh

            .refreshable {
                await loadDashboard()
            }

            .task(id: householdId) {
                await loadDashboard()
            }
        }
    }

    // MARK: - Load Firebase Data

    private func loadDashboard() async {

        guard let householdId else {
            applianceViewModel.reset()
            simulationViewModel.reset()
            return
        }

        async let applianceLoad: Void =
            applianceViewModel.loadAppliances(
                householdId: householdId
            )

        async let readingLoad: Void =
            simulationViewModel.loadReadings(
                householdId: householdId,
                date: Date()
            )

        _ = await (applianceLoad, readingLoad)
    }

    // MARK: - Statistic Card

    private func statisticCard(
        title: String,
        value: String,
        unit: String,
        icon: String
    ) -> some View {

        VStack(alignment: .leading, spacing: 10) {

            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(HomeWattTheme.primary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2.bold())
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding()
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 14)
        )
    }
}
