//
//  HouseholdViewModel.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-20.
//

import Foundation

import Foundation
import Observation
import FirebaseAuth

@MainActor
@Observable
final class HouseholdViewModel {

    private let householdService = HouseholdService.shared

    private(set) var household: Household?
    private(set) var isLoading = false
    private(set) var isSaving = false
    private(set) var errorMessage: String?

    // Prevent displaying onboarding until Firestore
    // has finished checking for an existing household.
    private(set) var hasLoadedHousehold = false

    var hasHousehold: Bool {
        household != nil
    }


    func loadHousehold() async {
        isLoading = true
        hasLoadedHousehold = false
        errorMessage = nil

        defer {
            isLoading = false
            hasLoadedHousehold = true
        }

        do {
            household = try await householdService.fetchHousehold()
        } catch {
            household = nil
            errorMessage = error.localizedDescription
        }
    }


    func createHousehold(
        name: String,
        type: HouseholdType,
        residents: Int,
        monthlyBudgetLKR: Double,
        highEnergyThresholdWatts: Double
    ) async -> Bool {

        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Please sign in before creating a household."
            return false
        }

        let cleanName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanName.isEmpty else {
            errorMessage = "Please enter a household name."
            return false
        }

        guard (1...20).contains(residents),
              monthlyBudgetLKR > 0,
              monthlyBudgetLKR.isFinite,
              highEnergyThresholdWatts > 0,
              highEnergyThresholdWatts.isFinite else {
            errorMessage = "Please enter valid household settings."
            return false
        }

        isSaving = true
        errorMessage = nil

        defer { isSaving = false }

        let newHousehold = Household(
            id: userId,
            ownerId: userId,
            name: cleanName,
            type: type,
            residents: residents,
            monthlyBudgetLKR: monthlyBudgetLKR,
            highEnergyThresholdWatts: highEnergyThresholdWatts
        )

        do {
            try await householdService.createHousehold(newHousehold)
            household = newHousehold
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }


    func updateHousehold(_ updatedHousehold: Household) async -> Bool {
        isSaving = true
        errorMessage = nil

        defer { isSaving = false }

        do {
            try await householdService.updateHousehold(updatedHousehold)
            household = updatedHousehold
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateElectricityRate(_ rate: Double) async -> Bool {

        guard rate.isFinite,
              rate > 0,
              rate <= 1000 else {
            errorMessage = "Please enter a valid electricity rate."
            return false
        }

        guard var updatedHousehold = household else {
            errorMessage = "No household is currently available."
            return false
        }

        updatedHousehold.electricityRatePerKWh = rate

        return await updateHousehold(updatedHousehold)
    }

    func reset() {
        household = nil
        isLoading = false
        isSaving = false
        errorMessage = nil
        hasLoadedHousehold = false
    }
}
