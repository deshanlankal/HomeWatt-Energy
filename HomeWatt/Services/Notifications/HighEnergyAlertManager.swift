
//
//  HighEnergyAlertManager.swift
//  HomeWatt
//

import Foundation

@MainActor
final class HighEnergyAlertManager {

    static let shared = HighEnergyAlertManager()

    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Alert State Key

    private func alertStateKey(
        householdId: String
    ) -> String {
        "homewatt.highEnergyAlertActive.\(householdId)"
    }

    // MARK: - Check High Energy Usage

    func checkEnergyUsage(
        householdId: String,
        appliances: [Appliance],
        thresholdWatts: Double
    ) async {

        let result = HighEnergyDetectionService.evaluate(
            appliances: appliances,
            thresholdWatts: thresholdWatts
        )

        let key = alertStateKey(householdId: householdId)

        let wasHighEnergy = defaults.bool(forKey: key)
        
        let alertsEnabled = defaults.object(
            forKey: "homewatt.highEnergyAlertsEnabled"
        ) as? Bool ?? true

        guard alertsEnabled else {
            // Clear the alert state while alerts are disabled.
            // This allows a fresh notification after re-enabling.
            defaults.set(false, forKey: key)
            return
        }


        if result.isHighEnergy {

            // Already alerted during this high-usage period.
            guard !wasHighEnergy else {
                return
            }

            // Only mark as alerted when notifications are permitted.
            guard await NotificationService.shared.notificationsEnabled() else {
                return
            }

            let scheduled = await NotificationService.shared.sendHighEnergyAlert(
                currentPowerWatts: result.currentPowerWatts,
                thresholdWatts: result.thresholdWatts
            )

            if scheduled { defaults.set(true, forKey: key) }

        } else {

            // Reset once power returns to normal.
            defaults.set(false, forKey: key)
        }
    }

    func clearState(householdId: String) {
        defaults.removeObject(forKey: alertStateKey(householdId: householdId))
    }
}
