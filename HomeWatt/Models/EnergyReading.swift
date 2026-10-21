//
//  EnergyReading.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-21.
//

import Foundation

//
//  EnergyReading.swift
//  HomeWatt


//
struct EnergyReading: Identifiable, Codable {

    var id: String
    var householdId: String

    // Start and end of the simulated reading interval.
    var intervalStart: Date
    var intervalEnd: Date

    // Total simulated electricity consumed during the interval.
    var energyKWh: Double

    // Average simulated power during the interval.
    var averagePowerWatts: Double

    // Indicates that this is generated, not metered, data.
    var source: String

    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        householdId: String,
        intervalStart: Date,
        intervalEnd: Date,
        energyKWh: Double,
        averagePowerWatts: Double,
        source: String = "simulation",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.householdId = householdId
        self.intervalStart = intervalStart
        self.intervalEnd = intervalEnd
        self.energyKWh = energyKWh
        self.averagePowerWatts = averagePowerWatts
        self.source = source
        self.createdAt = createdAt
    }
}
