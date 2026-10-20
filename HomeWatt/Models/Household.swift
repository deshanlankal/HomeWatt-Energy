//
//  Household.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-20.
//

import Foundation

import Foundation
import FirebaseFirestore

struct Household: Codable, Identifiable {

    // The household ID matches the Firebase user's UID.
    var id: String

    // Firebase user who owns this household.
    var ownerId: String

    // Household configuration.
    var name: String
    var type: HouseholdType
    var residents: Int

    // Energy monitoring preferences.
    var monthlyBudgetLKR: Double
    var highEnergyThresholdWatts: Double

    // Creation timestamp.
    var createdAt: Date

    init(
        id: String,
        ownerId: String,
        name: String,
        type: HouseholdType,
        residents: Int,
        monthlyBudgetLKR: Double,
        highEnergyThresholdWatts: Double,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.type = type
        self.residents = residents
        self.monthlyBudgetLKR = monthlyBudgetLKR
        self.highEnergyThresholdWatts = highEnergyThresholdWatts
        self.createdAt = createdAt
    }
}

enum HouseholdType: String, Codable, CaseIterable, Identifiable {
    case house
    case apartment

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .house:
            return "House"
        case .apartment:
            return "Apartment"
        }
    }
}
