//
//  ApplianceViewModel.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-21.
//


import Foundation
import Observation

@MainActor
@Observable
final class ApplianceViewModel {

    private let applianceService = ApplianceService.shared

    private(set) var appliances: [Appliance] = []
    private(set) var isLoading = false
    private(set) var isSaving = false
    private(set) var errorMessage: String?

    // MARK: - Load Appliances

    func loadAppliances(householdId: String) async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            appliances = try await applianceService.fetchAppliances(
                householdId: householdId
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Add Appliance

    func addAppliance(
        householdId: String,
        name: String,
        category: ApplianceCategory,
        ratedPowerWatts: Double,
        estimatedHoursPerDay: Double,
        highEnergyThresholdWatts: Double? = nil
    ) async -> Bool {

        let cleanName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanName.isEmpty,
              ratedPowerWatts.isFinite,
              ratedPowerWatts > 0,
              estimatedHoursPerDay.isFinite,
              (0...24).contains(estimatedHoursPerDay) else {
            errorMessage = "Please enter valid appliance details."
            return false
        }

        isSaving = true
        errorMessage = nil

        defer { isSaving = false }

        let appliance = Appliance(
            householdId: householdId,
            name: cleanName,
            category: category,
            ratedPowerWatts: ratedPowerWatts,
            estimatedHoursPerDay: estimatedHoursPerDay
        )

        do {
            try await applianceService.createAppliance(appliance)
            appliances.append(appliance)
            appliances.sort { $0.name < $1.name }
            await evaluateHighEnergy(thresholdWatts: highEnergyThresholdWatts, householdId: householdId)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Update Appliance

    func updateAppliance(_ appliance: Appliance, highEnergyThresholdWatts: Double? = nil) async -> Bool {
        isSaving = true
        errorMessage = nil

        defer { isSaving = false }

        do {
            try await applianceService.updateAppliance(appliance)

            if let index = appliances.firstIndex(
                where: { $0.id == appliance.id }
            ) {
                appliances[index] = appliance
            }

            appliances.sort { $0.name < $1.name }
            await evaluateHighEnergy(thresholdWatts: highEnergyThresholdWatts, householdId: appliance.householdId)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Toggle Appliance

    func toggleAppliance(_ appliance: Appliance, highEnergyThresholdWatts: Double? = nil) async -> Bool {
        var updatedAppliance = appliance
        updatedAppliance.isOn.toggle()

        return await updateAppliance(updatedAppliance, highEnergyThresholdWatts: highEnergyThresholdWatts)
    }

    // MARK: - Delete Appliance

    func deleteAppliance(_ appliance: Appliance, highEnergyThresholdWatts: Double? = nil) async -> Bool {
        isSaving = true
        errorMessage = nil

        defer { isSaving = false }

        do {
            try await applianceService.deleteAppliance(
                applianceId: appliance.id,
                householdId: appliance.householdId
            )

            appliances.removeAll { $0.id == appliance.id }
            await evaluateHighEnergy(thresholdWatts: highEnergyThresholdWatts, householdId: appliance.householdId)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func evaluateHighEnergy(thresholdWatts: Double?, householdId: String) async {
        guard let thresholdWatts, thresholdWatts > 0 else { return }
        await HighEnergyAlertManager.shared.checkEnergyUsage(householdId: householdId, appliances: appliances, thresholdWatts: thresholdWatts)
    }

    // MARK: - Simulated Power Summary

    var totalActivePowerWatts: Double {
        appliances
            .filter(\.isOn)
            .reduce(0) { $0 + $1.ratedPowerWatts }
    }

    var activeApplianceCount: Int {
        appliances.filter(\.isOn).count
    }

    // MARK: - Reset

    func reset() {
        appliances = []
        isLoading = false
        isSaving = false
        errorMessage = nil
    }
}
