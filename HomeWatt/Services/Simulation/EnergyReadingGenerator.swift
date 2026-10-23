//
//  EnergyReadingGenerator.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-21.
//

import Foundation

enum EnergyReadingGenerator {

    private static let intervalMinutes = 30
    private static let secondsPerHour = 3600.0

    static func generateDay(
        householdId: String,
        appliances: [Appliance],
        date: Date,
        calendar: Calendar = .current
    ) -> [EnergyReading] {

        let startOfDay = calendar.startOfDay(for: date)

        guard let nextDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfDay
        ) else {
            return []
        }

        var readings: [EnergyReading] = []
        var intervalStart = startOfDay
        var intervalIndex = 0

        while intervalStart < nextDay {

            guard let proposedEnd = calendar.date(
                byAdding: .minute,
                value: intervalMinutes,
                to: intervalStart
            ) else {
                break
            }

            let intervalEnd = min(proposedEnd, nextDay)

            let intervalHours = intervalEnd
                .timeIntervalSince(intervalStart) / secondsPerHour

            var totalEnergyKWh = 0.0

            for appliance in appliances {

                let operatingFraction = operatingFraction(
                    for: appliance,
                    intervalStart: intervalStart,
                    intervalEnd: intervalEnd,
                    calendar: calendar
                )

                totalEnergyKWh +=
                    EnergySimulationService.energyKWh(
                        powerWatts: appliance.ratedPowerWatts,
                        hours: intervalHours * operatingFraction
                    )
            }

            let averagePowerWatts = intervalHours > 0
                ? totalEnergyKWh * 1000 / intervalHours
                : 0

            // Stable ID prevents duplicate documents when
            // generating the same interval again.
            let readingId = String(
                Int(intervalStart.timeIntervalSince1970)
            )

            let reading = EnergyReading(
                id: readingId,
                householdId: householdId,
                intervalStart: intervalStart,
                intervalEnd: intervalEnd,
                energyKWh: totalEnergyKWh,
                averagePowerWatts: averagePowerWatts
            )

            readings.append(reading)

            intervalStart = intervalEnd
            intervalIndex += 1
        }

        return readings
    }


    private static func operatingFraction(
        for appliance: Appliance,
        intervalStart: Date,
        intervalEnd: Date,
        calendar: Calendar
    ) -> Double {

        let dailyHours = min(
            max(appliance.estimatedHoursPerDay, 0),
            24
        )

        guard dailyHours > 0 else {
            return 0
        }

        // Deterministic simulated start time, spread across
        // the day according to the appliance identifier.
        let startHour = simulatedStartHour(for: appliance.id)

        let intervalMidpoint = intervalStart.addingTimeInterval(
            intervalEnd.timeIntervalSince(intervalStart) / 2
        )

        let components = calendar.dateComponents(
            [.hour, .minute, .second],
            from: intervalMidpoint
        )

        let currentHour =
            Double(components.hour ?? 0) +
            Double(components.minute ?? 0) / 60 +
            Double(components.second ?? 0) / 3600

        // Handles schedules that cross midnight.
        let elapsed = (
            currentHour - startHour + 24
        ).truncatingRemainder(dividingBy: 24)

        // Fractional hours are approximated to the nearest
        // half-hour interval.
        if elapsed < dailyHours {
            return 1
        }

        return 0
    }

    private static func simulatedStartHour(
        for applianceId: String
    ) -> Double {

        let hash = applianceId.utf8.reduce(UInt64(0)) {
            ($0 &* 31) &+ UInt64($1)
        }

        let halfHourSlot = Int(hash % 48)

        return Double(halfHourSlot) / 2
    }
}
