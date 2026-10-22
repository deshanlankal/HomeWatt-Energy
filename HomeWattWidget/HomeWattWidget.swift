import WidgetKit
import SwiftUI
import ActivityKit

private struct EnergySnapshot: Codable {
    let activePowerWatts: Double
    let todayEnergyKWh: Double
    let estimatedMonthlyCostLKR: Double
    let isHighEnergy: Bool
    let updatedAt: Date
}

private struct EnergyEntry: TimelineEntry {
    let date: Date
    let snapshot: EnergySnapshot?
}

private struct EnergyProvider: TimelineProvider {
    func placeholder(in context: Context) -> EnergyEntry {
        EnergyEntry(date: .now, snapshot: EnergySnapshot(activePowerWatts: 840, todayEnergyKWh: 4.2, estimatedMonthlyCostLKR: 1260, isHighEnergy: false, updatedAt: .now))
    }
    func getSnapshot(in context: Context, completion: @escaping (EnergyEntry) -> Void) { completion(entry()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<EnergyEntry>) -> Void) {
        let current = entry()
        completion(Timeline(entries: [current], policy: .after(.now.addingTimeInterval(15 * 60))))
    }
    private func entry() -> EnergyEntry {
        let defaults = UserDefaults(suiteName: "group.com.deshanlanka.HomeWatt")
        let snapshot = defaults?.data(forKey: "homewatt.energySnapshot").flatMap { try? JSONDecoder().decode(EnergySnapshot.self, from: $0) }
        return EnergyEntry(date: .now, snapshot: snapshot)
    }
}

private struct HomeWattWidgetView: View {
    let entry: EnergyEntry
    var body: some View {
        if let item = entry.snapshot {
            VStack(alignment: .leading, spacing: 8) {
                Label("HomeWatt", systemImage: "bolt.fill").font(.headline).foregroundStyle(.green)
                Text("\(item.activePowerWatts, format: .number.precision(.fractionLength(0))) W").font(.title.bold())
                Text("Today \(item.todayEnergyKWh, format: .number.precision(.fractionLength(1))) kWh").font(.caption)
                Text("Est. Rs. \(item.estimatedMonthlyCostLKR, format: .number.precision(.fractionLength(0))) / month").font(.caption)
                if item.isHighEnergy { Label("High simulated usage", systemImage: "exclamationmark.triangle.fill").font(.caption).foregroundStyle(.orange) }
            }
            .padding()
            .background(Color(.systemBackground))
        } else {
            VStack(spacing: 8) {
                Image(systemName: "bolt.slash").font(.title).foregroundStyle(.secondary)
                Text("No Energy Data").font(.headline)
                Text("Open HomeWatt to refresh the simulated snapshot.")
                    .font(.caption).multilineTextAlignment(.center).foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
}

struct HomeWattWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "HomeWattWidget", provider: EnergyProvider()) { HomeWattWidgetView(entry: $0) }
            .configurationDisplayName("HomeWatt Energy")
            .description("Shows the latest simulated HomeWatt energy summary.")
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@available(iOS 16.1, *)
struct EnergyLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EnergyLiveActivityAttributes.self) { context in
            HStack {
                Image(systemName: context.state.isHighEnergy ? "exclamationmark.triangle.fill" : "bolt.fill")
                    .foregroundStyle(context.state.isHighEnergy ? .orange : .green)
                VStack(alignment: .leading) {
                    Text(context.attributes.householdName).font(.caption)
                    Text("\(context.state.activePowerWatts, format: .number.precision(.fractionLength(0))) W").font(.headline)
                }
                Spacer()
                Text("\(context.state.todayEnergyKWh, format: .number.precision(.fractionLength(1))) kWh").font(.caption)
            }
            .padding(.horizontal)
            .activityBackgroundTint(.black.opacity(0.15))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) { Image(systemName: "bolt.fill").foregroundStyle(.green) }
                DynamicIslandExpandedRegion(.trailing) { Text("\(context.state.activePowerWatts, format: .number.precision(.fractionLength(0))) W").font(.caption.bold()) }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack { Text(context.attributes.householdName); Spacer(); Text(context.state.isHighEnergy ? "High simulated usage" : "Simulated monitoring") }
                        .font(.caption)
                }
            } compactLeading: { Image(systemName: "bolt.fill").foregroundStyle(.green) }
            compactTrailing: { Text("\(context.state.activePowerWatts, format: .number.precision(.fractionLength(0)))") }
            minimal: { Image(systemName: "bolt.fill").foregroundStyle(.green) }
        }
    }
}

@main
struct HomeWattWidgetBundle: WidgetBundle {
    var body: some Widget {
        HomeWattWidget()
        if #available(iOS 16.1, *) { EnergyLiveActivityWidget() }
    }
}
