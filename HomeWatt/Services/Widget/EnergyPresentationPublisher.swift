import Foundation

struct EnergyPresentationMetrics {
    let activePowerWatts: Double
    let todayEnergyKWh: Double
    let estimatedMonthlyCostLKR: Double
    let highEnergyThresholdWatts: Double

    var isHighEnergy: Bool { activePowerWatts > highEnergyThresholdWatts }
}

@MainActor
enum EnergyPresentationPublisher {
    static func metrics(
        appliances: [Appliance],
        readings: [EnergyReading],
        household: Household
    ) -> EnergyPresentationMetrics {
        let simulation = EnergySimulationService.estimate(appliances: appliances)
        let recordedTodayEnergy = readings.reduce(0) { $0 + $1.energyKWh }
        let monthlyCost = ElectricityCostService.monthlyEstimate(
            appliances: appliances,
            ratePerKWh: household.electricityRatePerKWh
        ).totalCostLKR

        return EnergyPresentationMetrics(
            activePowerWatts: simulation.activePowerWatts,
            todayEnergyKWh: readings.isEmpty ? simulation.dailyEnergyKWh : recordedTodayEnergy,
            estimatedMonthlyCostLKR: monthlyCost,
            highEnergyThresholdWatts: household.highEnergyThresholdWatts
        )
    }

    static func publish(
        appliances: [Appliance],
        readings: [EnergyReading],
        household: Household
    ) async {
        let metrics = metrics(appliances: appliances, readings: readings, household: household)
        SharedEnergySnapshotStore.save(
            SharedEnergySnapshot(
                activePowerWatts: metrics.activePowerWatts,
                todayEnergyKWh: metrics.todayEnergyKWh,
                estimatedMonthlyCostLKR: metrics.estimatedMonthlyCostLKR,
                highEnergyThresholdWatts: metrics.highEnergyThresholdWatts,
                isHighEnergy: metrics.isHighEnergy,
                updatedAt: Date()
            )
        )

        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            await EnergyLiveActivityManager.shared.update(
                power: metrics.activePowerWatts,
                todayEnergy: metrics.todayEnergyKWh,
                monthlyCost: metrics.estimatedMonthlyCostLKR,
                threshold: metrics.highEnergyThresholdWatts
            )
        }
        #endif
    }
}
