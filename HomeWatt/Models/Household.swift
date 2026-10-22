
//
//  Household.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-20.
//

import Foundation
import FirebaseFirestore

struct Household: Codable, Identifiable {

    // MARK: - Identity

    var id: String
    var ownerId: String

    // MARK: - Household Configuration

    var name: String
    var type: HouseholdType
    var residents: Int

    // MARK: - Energy Preferences

    var monthlyBudgetLKR: Double
    var highEnergyThresholdWatts: Double

    // Electricity rate in Sri Lankan Rupees per kWh.
    var electricityRatePerKWh: Double

    // MARK: - Metadata

    var createdAt: Date

    // MARK: - Initializer

    init(
        id: String,
        ownerId: String,
        name: String,
        type: HouseholdType,
        residents: Int,
        monthlyBudgetLKR: Double,
        highEnergyThresholdWatts: Double,
        electricityRatePerKWh: Double = 30.0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.type = type
        self.residents = residents
        self.monthlyBudgetLKR = monthlyBudgetLKR
        self.highEnergyThresholdWatts = highEnergyThresholdWatts
        self.electricityRatePerKWh = electricityRatePerKWh
        self.createdAt = createdAt
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case ownerId
        case name
        case type
        case residents
        case monthlyBudgetLKR
        case highEnergyThresholdWatts
        case electricityRatePerKWh
        case createdAt
    }

    // MARK: - Backward-Compatible Decoding

    init(from decoder: Decoder) throws {

        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        id = try container.decode(
            String.self,
            forKey: .id
        )

        ownerId = try container.decode(
            String.self,
            forKey: .ownerId
        )

        name = try container.decode(
            String.self,
            forKey: .name
        )

        type = try container.decode(
            HouseholdType.self,
            forKey: .type
        )

        residents = try container.decode(
            Int.self,
            forKey: .residents
        )

        monthlyBudgetLKR = try container.decode(
            Double.self,
            forKey: .monthlyBudgetLKR
        )

        highEnergyThresholdWatts = try container.decode(
            Double.self,
            forKey: .highEnergyThresholdWatts
        )

        // Existing Firestore documents may not have this field.
        electricityRatePerKWh = try container.decodeIfPresent(
            Double.self,
            forKey: .electricityRatePerKWh
        ) ?? 30.0

        createdAt = try container.decode(
            Date.self,
            forKey: .createdAt
        )
    }
}

// MARK: - Household Type

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
