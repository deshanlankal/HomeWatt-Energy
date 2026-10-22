//
//  HomeWattTests.swift
//  HomeWattTests
//
//  Created by Deshan Lanka on 2026-10-01.
//

import Testing
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

}
