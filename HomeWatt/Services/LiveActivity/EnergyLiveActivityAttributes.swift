import Foundation
import ActivityKit

@available(iOS 16.1, *)
struct EnergyLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var activePowerWatts: Double
        var todayEnergyKWh: Double
        var estimatedMonthlyCostLKR: Double
        var isHighEnergy: Bool
    }

    var householdName: String
}
