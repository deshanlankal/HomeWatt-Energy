//
//  ElectricityCostService.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-21.
//

import Foundation

struct ElectricityCostEstimate {
    let energyKWh: Double
    let ratePerKWh: Double
    let energyChargeLKR: Double
    let fixedChargeLKR: Double
    let totalCostLKR: Double
}

enum ElectricityCostService {

    // Example rate for simulation only.
    // Not an official Sri Lankan electricity tariff.
    static let defaultRatePerKWh = 30.0

    static func estimate(
        energyKWh: Double,
        ratePerKWh: Double = defaultRatePerKWh,
        fixedChargeLKR: Double = 0
    ) -> ElectricityCostEstimate {

        let validEnergy = energyKWh.isFinite
            ? max(0, energyKWh)
            : 0

        let validRate = ratePerKWh.isFinite
            ? max(0, ratePerKWh)
            : 0

        let validFixedCharge = fixedChargeLKR.isFinite
            ? max(0, fixedChargeLKR)
            : 0

        let energyCharge = validEnergy * validRate

        return ElectricityCostEstimate(
            energyKWh: validEnergy,
            ratePerKWh: validRate,
            energyChargeLKR: energyCharge,
            fixedChargeLKR: validFixedCharge,
            totalCostLKR: energyCharge + validFixedCharge
        )
    }

    static func monthlyEstimate(
        appliances: [Appliance],
        ratePerKWh: Double = defaultRatePerKWh
    ) -> ElectricityCostEstimate {

        let energySummary = EnergySimulationService.estimate(
            appliances: appliances
        )

        return estimate(
            energyKWh: energySummary.monthlyEnergyKWh,
            ratePerKWh: ratePerKWh
        )
    }

    static func formatLKR(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "LKR"
        formatter.currencySymbol = "Rs. "
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(
            from: NSNumber(value: amount)
        ) ?? "Rs. 0.00"
    }
}

