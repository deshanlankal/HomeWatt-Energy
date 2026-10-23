import WidgetKit
import SwiftUI
import ActivityKit
import Foundation

private struct EnergySnapshot: Codable {
    let activePowerWatts: Double
    let todayEnergyKWh: Double
    let estimatedMonthlyCostLKR: Double
    let highEnergyThresholdWatts: Double?
    let isHighEnergy: Bool
    let updatedAt: Date
}

private struct EnergyEntry: TimelineEntry {
    let date: Date
    let snapshot: EnergySnapshot?
}

private struct EnergyProvider: TimelineProvider {
    func placeholder(in context: Context) -> EnergyEntry {
        EnergyEntry(date: .now, snapshot: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (EnergyEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EnergyEntry>) -> Void) {
        completion(Timeline(entries: [entry()], policy: .after(.now.addingTimeInterval(15 * 60))))
    }

    private func entry() -> EnergyEntry {
        let defaults = UserDefaults(suiteName: "group.com.deshanlanka.HomeWatt")
        let snapshot = defaults?.data(forKey: "homewatt.energySnapshot")
            .flatMap { try? JSONDecoder().decode(EnergySnapshot.self, from: $0) }
        return EnergyEntry(date: .now, snapshot: snapshot)
    }
}

private extension EnergySnapshot {
    static let preview = EnergySnapshot(
        activePowerWatts: 840,
        todayEnergyKWh: 4.2,
        estimatedMonthlyCostLKR: 1_260,
        highEnergyThresholdWatts: 1_200,
        isHighEnergy: false,
        updatedAt: .now
    )

    var thresholdProgress: Double? {
        guard let highEnergyThresholdWatts, highEnergyThresholdWatts > 0 else { return nil }
        return min(activePowerWatts / highEnergyThresholdWatts, 1)
    }

    var statusTitle: String { isHighEnergy ? "High simulated usage" : "Usage normal" }
    var statusColor: Color { isHighEnergy ? .orange : .green }
}

private struct HomeWattWidgetBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.04, green: 0.22, blue: 0.16),
                Color(red: 0.08, green: 0.48, blue: 0.32)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private extension View {
    @ViewBuilder
    func homeWattWidgetSurface() -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget) {
                HomeWattWidgetBackground()
            }
        } else {
            background(HomeWattWidgetBackground())
        }
    }
}

private struct HomeWattWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: EnergyEntry

    var body: some View {
        Group {
            if let snapshot = entry.snapshot {
                switch family {
                case .systemLarge:
                    largeSummary(snapshot)
                case .systemMedium:
                    mediumSummary(snapshot)
                default:
                    compactSummary(snapshot)
                }
            } else {
                emptyState
            }
        }
        .homeWattWidgetSurface()
    }

    private func compactSummary(_ snapshot: EnergySnapshot) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            widgetHeader
            Spacer(minLength: 0)
            Text(snapshot.activePowerWatts, format: .number.precision(.fractionLength(0)))
                .font(.system(size: 30, weight: .bold, design: .rounded))
            Text("W active power")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.78))
            statusBadge(snapshot)
        }
        .foregroundStyle(.white)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary(snapshot))
    }

    private func mediumSummary(_ snapshot: EnergySnapshot) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 9) {
                widgetHeader
                Text(snapshot.activePowerWatts, format: .number.precision(.fractionLength(0)))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text("W active power")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.78))
                statusBadge(snapshot)
            }

            Divider().overlay(.white.opacity(0.24))

            VStack(alignment: .leading, spacing: 12) {
                metricRow(icon: "bolt.fill", title: "Today", value: "\(String(format: "%.1f", snapshot.todayEnergyKWh)) kWh")
                metricRow(icon: "calendar", title: "Monthly", value: "Rs. \(String(format: "%.0f", snapshot.estimatedMonthlyCostLKR))")
                freshnessLabel(snapshot)
            }
        }
        .foregroundStyle(.white)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary(snapshot))
    }

    private func largeSummary(_ snapshot: EnergySnapshot) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            widgetHeader

            HStack(alignment: .center, spacing: 18) {
                powerGauge(snapshot)
                    .frame(width: 105, height: 105)

                VStack(alignment: .leading, spacing: 12) {
                    metricRow(icon: "bolt.fill", title: "Today's energy", value: "\(String(format: "%.2f", snapshot.todayEnergyKWh)) kWh")
                    metricRow(icon: "creditcard", title: "Monthly estimate", value: "Rs. \(String(format: "%.0f", snapshot.estimatedMonthlyCostLKR))")
                    statusBadge(snapshot)
                }
            }

            Spacer(minLength: 0)
            freshnessLabel(snapshot)
        }
        .foregroundStyle(.white)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary(snapshot))
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bolt.slash.fill")
                .font(.title)
                .foregroundStyle(.white.opacity(0.82))
            Text("No Energy Snapshot")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Open HomeWatt to refresh your simulated energy summary.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.75))
        }
        .accessibilityElement(children: .combine)
    }

    private var widgetHeader: some View {
        Label("HomeWatt", systemImage: "bolt.circle.fill")
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
    }

    private func statusBadge(_ snapshot: EnergySnapshot) -> some View {
        Label(snapshot.statusTitle, systemImage: snapshot.isHighEnergy ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
            .font(.caption2.weight(.bold))
            .foregroundStyle(snapshot.statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.white.opacity(0.94), in: Capsule())
    }

    private func metricRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.72))
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.caption2).foregroundStyle(.white.opacity(0.68))
                Text(value).font(.caption.weight(.semibold))
            }
        }
    }

    private func freshnessLabel(_ snapshot: EnergySnapshot) -> some View {
        Label {
            Text("Updated \(snapshot.updatedAt, style: .relative)")
        } icon: {
            Image(systemName: "arrow.clockwise")
        }
        .font(.caption2)
        .foregroundStyle(.white.opacity(0.68))
    }

    fileprivate func powerGauge(_ snapshot: EnergySnapshot) -> some View {
        ZStack {
            Circle().stroke(.white.opacity(0.18), lineWidth: 11)
            if let progress = snapshot.thresholdProgress {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(snapshot.statusColor, style: StrokeStyle(lineWidth: 11, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            VStack(spacing: 2) {
                Text(snapshot.activePowerWatts, format: .number.precision(.fractionLength(0)))
                    .font(.title3.bold())
                Text("watts").font(.caption2).foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    private func accessibilitySummary(_ snapshot: EnergySnapshot) -> String {
        "HomeWatt. \(Int(snapshot.activePowerWatts)) watts active power. \(String(format: "%.1f", snapshot.todayEnergyKWh)) kilowatt-hours today. Estimated monthly cost \(Int(snapshot.estimatedMonthlyCostLKR)) rupees. \(snapshot.statusTitle)."
    }
}

private struct PowerMonitorWidgetView: View {
    let entry: EnergyEntry

    var body: some View {
        Group {
            if let snapshot = entry.snapshot {
                VStack(spacing: 3) {
                    Label("Power", systemImage: "gauge.with.dots.needle.50percent")
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                    HomeWattWidgetView(entry: entry).powerGauge(snapshot)
                        .frame(width: 78, height: 78)
                    Text(snapshot.highEnergyThresholdWatts.map { "Limit \(Int($0)) W" } ?? "No limit set")
                        .font(.caption2)
                        .lineLimit(1)
                        .foregroundStyle(.white.opacity(0.72))
                }
                .padding(6)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Power monitor. \(Int(snapshot.activePowerWatts)) watts. \(snapshot.statusTitle).")
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "gauge.with.dots.needle.50percent")
                        .font(.title)
                        .foregroundStyle(.secondary)
                    Text("No Power Data").font(.headline)
                    Text("Open HomeWatt to refresh the widget.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .foregroundStyle(.white)
        .homeWattWidgetSurface()
    }
}

struct HomeWattWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "HomeWattWidget", provider: EnergyProvider()) { HomeWattWidgetView(entry: $0) }
            .configurationDisplayName("HomeWatt Energy")
            .description("Shows the latest simulated energy summary and estimated cost.")
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct HomeWattPowerWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "HomeWattPowerWidget", provider: EnergyProvider()) { PowerMonitorWidgetView(entry: $0) }
            .configurationDisplayName("HomeWatt Power Monitor")
            .description("Shows simulated active power against your household threshold.")
            .supportedFamilies([.systemSmall])
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
        HomeWattPowerWidget()
        if #available(iOS 16.1, *) { EnergyLiveActivityWidget() }
    }
}
