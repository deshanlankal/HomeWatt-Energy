import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Codable bridge for the WidgetKit extension. The app group must be enabled before shipping.
struct SharedEnergySnapshot: Codable {
    let activePowerWatts: Double
    let todayEnergyKWh: Double
    let estimatedMonthlyCostLKR: Double
    let isHighEnergy: Bool
    let updatedAt: Date
}

enum SharedEnergySnapshotStore {
    static let appGroupIdentifier = "group.com.deshanlanka.HomeWatt"
    private static let key = "homewatt.energySnapshot"

    static func save(_ snapshot: SharedEnergySnapshot) {
        let defaults = UserDefaults(suiteName: appGroupIdentifier) ?? .standard
        defaults.set(try? JSONEncoder().encode(snapshot), forKey: key)
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: "HomeWattWidget")
        #endif
    }

    static func load() -> SharedEnergySnapshot? {
        let defaults = UserDefaults(suiteName: appGroupIdentifier) ?? .standard
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(SharedEnergySnapshot.self, from: data)
    }
}
