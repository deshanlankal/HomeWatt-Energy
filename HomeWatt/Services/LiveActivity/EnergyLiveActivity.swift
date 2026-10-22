import Foundation
import Combine
#if canImport(ActivityKit)
import ActivityKit

@available(iOS 16.1, *)
@MainActor
final class EnergyLiveActivityManager: ObservableObject {
    static let shared = EnergyLiveActivityManager()
    @Published private(set) var isRunning = false
    private var activity: Activity<EnergyLiveActivityAttributes>?

    func start(householdName: String, power: Double, todayEnergy: Double, monthlyCost: Double, threshold: Double) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled, activity == nil else { return }
        let attributes = EnergyLiveActivityAttributes(householdName: householdName)
        let state = EnergyLiveActivityAttributes.ContentState(activePowerWatts: power, todayEnergyKWh: todayEnergy, estimatedMonthlyCostLKR: monthlyCost, isHighEnergy: power > threshold)
        do { activity = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil)); isRunning = true }
        catch { print("Unable to start Live Activity: \(error.localizedDescription)") }
    }

    func update(power: Double, todayEnergy: Double, monthlyCost: Double, threshold: Double) async {
        guard let activity else { return }
        let state = EnergyLiveActivityAttributes.ContentState(activePowerWatts: power, todayEnergyKWh: todayEnergy, estimatedMonthlyCostLKR: monthlyCost, isHighEnergy: power > threshold)
        await activity.update(.init(state: state, staleDate: nil))
    }

    func end() async {
        guard let activity else { return }
        await activity.end(nil, dismissalPolicy: .default)
        self.activity = nil; isRunning = false
    }
}
#endif
