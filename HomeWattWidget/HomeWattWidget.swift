import WidgetKit
import SwiftUI

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

struct HomeWattWidgetView: View {
    let entry: EnergyEntry
    var body: some View {
        if let item = entry.snapshot {
            VStack(alignment: .leading, spacing: 8) {
                Label("HomeWatt", systemImage: "bolt.fill").font(.headline).foregroundStyle(.green)
                Text("\(item.activePowerWatts, format: .number.precision(.fractionLength(0))) W").font(.title.bold())
                Text("Today \(item.todayEnergyKWh, format: .number.precision(.fractionLength(1))) kWh").font(.caption)
                Text("Est. Rs. \(item.estimatedMonthlyCostLKR, format: .number.precision(.fractionLength(0))) / month").font(.caption)
                if item.isHighEnergy { Label("High simulated usage", systemImage: "exclamationmark.triangle.fill").font(.caption).foregroundStyle(.orange) }
            }.containerBackground(.fill.tertiary, for: .widget)
        } else {
            ContentUnavailableView("No Energy Data", systemImage: "bolt.slash", description: Text("Open HomeWatt to refresh the simulated snapshot."))
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

@main
struct HomeWattWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "HomeWattWidget", provider: EnergyProvider()) { HomeWattWidgetView(entry: $0) }
            .configurationDisplayName("HomeWatt Energy")
            .description("Shows the latest simulated HomeWatt energy summary.")
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}
