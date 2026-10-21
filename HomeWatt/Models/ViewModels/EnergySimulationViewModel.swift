//
//  EnergySimulationViewModel.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-21.
//

import Foundation
import Observation

@MainActor
@Observable
final class EnergySimulationViewModel {

    private let applianceService = ApplianceService.shared
    private let readingService = EnergyReadingService.shared

    private(set) var readings: [EnergyReading] = []
    private(set) var isGenerating = false
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var successMessage: String?

    // MARK: - Generate and Save One Day

    func generateDay(
        householdId: String,
        date: Date
    ) async -> Bool {

        guard !isGenerating else { return false }

        isGenerating = true
        errorMessage = nil
        successMessage = nil

        defer { isGenerating = false }

        do {
            // Fetch the latest appliance configurations.
            let appliances = try await applianceService.fetchAppliances(
                householdId: householdId
            )

            guard !appliances.isEmpty else {
                errorMessage = "Add at least one appliance before generating history."
                return false
            }

            // Generate deterministic simulated readings.
            let generated = EnergyReadingGenerator.generateDay(
                householdId: householdId,
                appliances: appliances,
                date: date
            )

            guard !generated.isEmpty else {
                errorMessage = "No readings could be generated."
                return false
            }

            // Save readings to Firestore.
            try await readingService.saveReadings(generated)

            // Refresh readings for the selected day.
            await loadReadings(
                householdId: householdId,
                date: date
            )

            guard errorMessage == nil else {
                return false
            }

            successMessage = "Generated \(generated.count) simulated readings."
            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Load One Day

    func loadReadings(
        householdId: String,
        date: Date
    ) async {

        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)

        guard let end = calendar.date(
            byAdding: .day,
            value: 1,
            to: start
        ) else {
            errorMessage = "Invalid date selected."
            return
        }

        do {
            readings = try await readingService.fetchReadings(
                householdId: householdId,
                from: start,
                to: end
            )
        } catch {
            readings = []
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Summary

    var totalEnergyKWh: Double {
        readings.reduce(0) { $0 + $1.energyKWh }
    }

    var peakPowerWatts: Double {
        readings.map(\.averagePowerWatts).max() ?? 0
    }

    var averagePowerWatts: Double {
        guard !readings.isEmpty else { return 0 }

        return readings.reduce(0) {
            $0 + $1.averagePowerWatts
        } / Double(readings.count)
    }

    // MARK: - Reset

    func reset() {
        readings = []
        isGenerating = false
        isLoading = false
        errorMessage = nil
        successMessage = nil
    }
}
