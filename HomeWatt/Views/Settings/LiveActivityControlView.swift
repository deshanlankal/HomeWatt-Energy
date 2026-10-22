import SwiftUI

struct LiveActivityControlView: View {
    @Environment(HouseholdViewModel.self) private var householdViewModel
    @State private var appliances = ApplianceViewModel()
    @State private var simulation = EnergySimulationViewModel()
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
                    else {
                        let metrics = EnergyPresentationPublisher.metrics(
                            appliances: appliances.appliances,
                            readings: simulation.readings,
                            household: household
                        )
                        manager.start(
                            householdName: household.name,
                            power: metrics.activePowerWatts,
                            todayEnergy: metrics.todayEnergyKWh,
                            monthlyCost: metrics.estimatedMonthlyCostLKR,
                            threshold: metrics.highEnergyThresholdWatts
                        )
                    }
                }
            } else { Text("Live Activities require iOS 16.1 or later.") }
            #else
            Text("Live Activities are not available in this build.")
            #endif
        }
        .task(id: householdViewModel.household?.id) {
            guard let household = householdViewModel.household else { return }
            async let appliancesLoad: Void = appliances.loadAppliances(householdId: household.id)
            async let readingsLoad: Void = simulation.loadReadings(householdId: household.id, date: Date())
            _ = await (appliancesLoad, readingsLoad)
            await EnergyPresentationPublisher.publish(
                appliances: appliances.appliances,
                readings: simulation.readings,
                household: household
            )
        }
        .onChange(of: appliances.totalActivePowerWatts) { _, _ in
            Task {
                guard let household = householdViewModel.household else { return }
                await EnergyPresentationPublisher.publish(appliances: appliances.appliances, readings: simulation.readings, household: household)
            }
        }
    }
}
