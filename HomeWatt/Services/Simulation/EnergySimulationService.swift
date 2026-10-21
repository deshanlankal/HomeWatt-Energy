//
//  EnergySimulationService.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-21.
//

import Foundation

struct ApplianceEnergyEstimate: Identifiable {
    let applianceId: String
    let applianceName: String
    let dailyEnergyKWh: Double

    var id: String { applianceId }
}

struct EnergySimulationSummary {
    let dailyEnergyKWh: Double
    let weeklyEnergyKWh: Double
    let monthlyEnergyKWh: Double
    let activePowerWatts: Double
    let applianceEstimates: [ApplianceEnergyEstimate]
}

enum EnergySimulationService {

    static func energyKWh(
        powerWatts: Double,
        hours: Double
    ) -> Double {
        guard powerWatts.isFinite,
              hours.isFinite,
              powerWatts >= 0,
              hours >= 0 else {
            return 0
        }

        return (powerWatts * hours) / 1000
    }

    static func estimate(
        appliances: [Appliance]
    ) -> EnergySimulationSummary {

        let estimates = appliances.map { appliance in
            ApplianceEnergyEstimate(
                applianceId: appliance.id,
                applianceName: appliance.name,
                dailyEnergyKWh: energyKWh(
                    powerWatts: appliance.ratedPowerWatts,
                    hours: appliance.estimatedHoursPerDay
                )
            )
        }

        let daily = estimates.reduce(0) {
            $0 + $1.dailyEnergyKWh
        }

        let activePower = appliances
            .filter(\.isOn)
            .reduce(0) {
                $0 + $1.ratedPowerWatts
            }

        return EnergySimulationSummary(
            dailyEnergyKWh: daily,
            weeklyEnergyKWh: daily * 7,
            monthlyEnergyKWh: daily * 30,
            activePowerWatts: activePower,
            applianceEstimates: estimates
        )
    }
}
