import SwiftUI

struct LiveActivityControlView: View {
    @Environment(HouseholdViewModel.self) private var householdViewModel
    @StateObject private var appliances = ApplianceViewModel()
    #if canImport(ActivityKit)
    @StateObject private var manager = EnergyLiveActivityManager.shared
    #endif

    var body: some View {
        Section("Live Activity") {
            Text("Shows simulated usage only. Updates occur while HomeWatt is running; iOS does not provide continuous background monitoring.")
                .font(.footnote).foregroundStyle(.secondary)
            #if canImport(ActivityKit)
            if #available(iOS 16.1, *), let household = householdViewModel.household {
                Button(manager.isRunning ? "Stop Energy Live Activity" : "Start Energy Live Activity") {
                    if manager.isRunning { Task { await manager.end() } }
                    else { manager.start(householdName: household.name, power: appliances.totalActivePowerWatts, todayEnergy: 0, monthlyCost: 0, threshold: household.highEnergyThresholdWatts) }
                }
            } else { Text("Live Activities require iOS 16.1 or later.") }
            #else
            Text("Live Activities are not available in this build.")
            #endif
        }
        .task(id: householdViewModel.household?.id) {
            if let id = householdViewModel.household?.id { await appliances.loadAppliances(householdId: id) }
        }
    }
}
