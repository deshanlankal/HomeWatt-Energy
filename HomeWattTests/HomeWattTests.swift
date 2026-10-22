//
//  HomeWattTests.swift
//  HomeWattTests
//
//  Created by Deshan Lanka on 2026-10-01.
//

import Testing
import Foundation
@testable import HomeWatt

struct HomeWattTests {

    @Test func highEnergyOnlyCrossesStrictlyAboveThreshold() {
        let atThreshold = HighEnergyDetectionService.evaluate(currentPowerWatts: 1000, thresholdWatts: 1000)
        let aboveThreshold = HighEnergyDetectionService.evaluate(currentPowerWatts: 1001, thresholdWatts: 1000)

        #expect(!atThreshold.isHighEnergy)
        #expect(aboveThreshold.isHighEnergy)
        #expect(aboveThreshold.excessPowerWatts == 1)
    }

    @Test func invalidPowerIsNormalisedSafely() {
        let result = HighEnergyDetectionService.evaluate(currentPowerWatts: .infinity, thresholdWatts: 500)
        #expect(result.currentPowerWatts == 0)
        #expect(!result.isHighEnergy)
    }

    @Test @MainActor func presentationUsesRecordedTodayEnergyAndMonthlyCost() {
        let household = Household(
            id: "household-1",
            ownerId: "user-1",
            name: "Test Home",
            type: .house,
            residents: 2,
            monthlyBudgetLKR: 10_000,
            highEnergyThresholdWatts: 500,
            electricityRatePerKWh: 25
        )
        let appliance = Appliance(
            householdId: household.id,
            name: "Fan",
            category: .fan,
            ratedPowerWatts: 100,
            isOn: true,
            estimatedHoursPerDay: 8
        )
        let reading = EnergyReading(
            householdId: household.id,
            intervalStart: .now,
            intervalEnd: .now.addingTimeInterval(1800),
            energyKWh: 0.4,
            averagePowerWatts: 800
        )

        let metrics = EnergyPresentationPublisher.metrics(
            appliances: [appliance],
            readings: [reading],
            household: household
        )

        #expect(metrics.activePowerWatts == 100)
        #expect(metrics.todayEnergyKWh == 0.4)
        #expect(metrics.estimatedMonthlyCostLKR == 600)
        #expect(!metrics.isHighEnergy)
    }

    @Test @MainActor func presentationFallsBackToSimulatedDailyEnergy() {
        let household = Household(
            id: "household-1",
            ownerId: "user-1",
            name: "Test Home",
            type: .house,
            residents: 1,
            monthlyBudgetLKR: 5_000,
            highEnergyThresholdWatts: 100,
            electricityRatePerKWh: 30
        )
        let appliance = Appliance(
            householdId: household.id,
            name: "Heater",
            category: .heater,
            ratedPowerWatts: 200,
            isOn: true,
            estimatedHoursPerDay: 3
        )

        let metrics = EnergyPresentationPublisher.metrics(
            appliances: [appliance],
            readings: [],
            household: household
        )

        #expect(metrics.todayEnergyKWh == 0.6)
        #expect(metrics.isHighEnergy)
    }

}
