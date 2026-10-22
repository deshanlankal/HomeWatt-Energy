//
//  HighEnergyDetectionService.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-22.
//

import Foundation


//
//  HighEnergyDetectionService.swift
//  HomeWatt
//

struct HighEnergyDetectionResult {

    let currentPowerWatts: Double
    let thresholdWatts: Double
    let isHighEnergy: Bool
    let excessPowerWatts: Double
    let usagePercentage: Double
}

enum HighEnergyDetectionService {

    static func evaluate(
        currentPowerWatts: Double,
        thresholdWatts: Double
    ) -> HighEnergyDetectionResult {

        let power = currentPowerWatts.isFinite
            ? max(0, currentPowerWatts)
            : 0

        let threshold = thresholdWatts.isFinite
            ? max(0, thresholdWatts)
            : 0

        let isHighEnergy = threshold > 0 && power > threshold

        let excessPower = isHighEnergy
            ? power - threshold
            : 0

        let percentage = threshold > 0
            ? (power / threshold) * 100
            : 0

        return HighEnergyDetectionResult(
            currentPowerWatts: power,
            thresholdWatts: threshold,
            isHighEnergy: isHighEnergy,
            excessPowerWatts: excessPower,
            usagePercentage: percentage
        )
    }

    static func evaluate(
        appliances: [Appliance],
        thresholdWatts: Double
    ) -> HighEnergyDetectionResult {

        let activePower = appliances
            .filter { $0.isOn }
            .reduce(0.0) { total, appliance in
                total + appliance.ratedPowerWatts
            }

        return evaluate(
            currentPowerWatts: activePower,
            thresholdWatts: thresholdWatts
        )
    }
}
