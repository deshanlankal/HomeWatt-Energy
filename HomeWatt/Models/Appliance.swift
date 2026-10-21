//
//  Appliance.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-21.
//

import Foundation
import FirebaseFirestore

enum ApplianceCategory: String, Codable, CaseIterable, Identifiable {
    case airConditioner
    case refrigerator
    case television
    case washingMachine
    case fan
    case lighting
    case heater
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .airConditioner: "Air Conditioner"
        case .refrigerator: "Refrigerator"
        case .television: "Television"
        case .washingMachine: "Washing Machine"
        case .fan: "Fan"
        case .lighting: "Lighting"
        case .heater: "Heater"
        case .other: "Other"
        }
    }

    var symbolName: String {
        switch self {
        case .airConditioner: "air.conditioner.horizontal"
        case .refrigerator: "refrigerator"
        case .television: "tv"
        case .washingMachine: "washer"
        case .fan: "fan"
        case .lighting: "lightbulb"
        case .heater: "heater.vertical"
        case .other: "powerplug"
        }
    }
}

struct Appliance: Identifiable, Codable {
    var id: String
    var householdId: String
    var name: String
    var category: ApplianceCategory

    // User-configured simulated electrical power.
    var ratedPowerWatts: Double

    // Whether this virtual appliance is switched on.
    var isOn: Bool

    // Planned daily usage for future simulation.
    var estimatedHoursPerDay: Double

    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        householdId: String,
        name: String,
        category: ApplianceCategory,
        ratedPowerWatts: Double,
        isOn: Bool = false,
        estimatedHoursPerDay: Double = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.householdId = householdId
        self.name = name
        self.category = category
        self.ratedPowerWatts = ratedPowerWatts
        self.isOn = isOn
        self.estimatedHoursPerDay = estimatedHoursPerDay
        self.createdAt = createdAt
    }
}
