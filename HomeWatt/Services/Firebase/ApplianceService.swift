//
//  ApplianceService.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-21.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

enum ApplianceServiceError: LocalizedError {
    case notAuthenticated
    case invalidHousehold
    case invalidAppliance
    case applianceNotFound

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to manage appliances."
        case .invalidHousehold:
            return "You cannot access this household."
        case .invalidAppliance:
            return "The appliance information is invalid."
        case .applianceNotFound:
            return "The appliance could not be found."
        }
    }
}

@MainActor
final class ApplianceService {

    static let shared = ApplianceService()

    private let database = Firestore.firestore()

    private init() {}

    // MARK: - Firestore References

    private func appliancesReference(
        householdId: String
    ) throws -> CollectionReference {

        guard let userId = Auth.auth().currentUser?.uid else {
            throw ApplianceServiceError.notAuthenticated
        }

        // Each household document is identified by its owner's UID.
        guard householdId == userId else {
            throw ApplianceServiceError.invalidHousehold
        }

        return database
            .collection("households")
            .document(householdId)
            .collection("appliances")
    }

    // MARK: - Create Appliance

    func createAppliance(_ appliance: Appliance) async throws {
        let collection = try appliancesReference(
            householdId: appliance.householdId
        )

        try validate(appliance)

        let reference = collection.document(appliance.id)

        // Prevent accidentally replacing an existing appliance.
        guard try await !reference.getDocument().exists else {
            throw ApplianceServiceError.invalidAppliance
        }

        try reference.setData(from: appliance)
    }

    // MARK: - Fetch Appliances

    func fetchAppliances(
        householdId: String
    ) async throws -> [Appliance] {

        let collection = try appliancesReference(
            householdId: householdId
        )

        let snapshot = try await collection.getDocuments()

        return try snapshot.documents.map {
            try $0.data(as: Appliance.self)
        }
        .sorted { $0.name < $1.name }
    }

    // MARK: - Update Appliance

    func updateAppliance(_ appliance: Appliance) async throws {
        let collection = try appliancesReference(
            householdId: appliance.householdId
        )

        try validate(appliance)

        let reference = collection.document(appliance.id)

        guard try await reference.getDocument().exists else {
            throw ApplianceServiceError.applianceNotFound
        }

        try reference.setData(from: appliance)
    }

    // MARK: - Delete Appliance

    func deleteAppliance(
        applianceId: String,
        householdId: String
    ) async throws {

        guard !applianceId.isEmpty,
              !applianceId.contains("/") else {
            throw ApplianceServiceError.invalidAppliance
        }

        let collection = try appliancesReference(
            householdId: householdId
        )

        try await collection.document(applianceId).delete()
    }

    // MARK: - Validation

    private func validate(_ appliance: Appliance) throws {
        let name = appliance.name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !appliance.id.isEmpty,
              !appliance.id.contains("/"),
              !name.isEmpty,
              appliance.ratedPowerWatts.isFinite,
              appliance.ratedPowerWatts > 0,
              appliance.estimatedHoursPerDay.isFinite,
              (0...24).contains(appliance.estimatedHoursPerDay) else {
            throw ApplianceServiceError.invalidAppliance
        }
    }
}

