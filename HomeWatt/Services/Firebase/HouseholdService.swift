//
//  HouseholdService.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-20.
//

import Foundation

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class HouseholdService {

    static let shared = HouseholdService()

    private let database = Firestore.firestore()

    private init() {}

    // MARK: - Household Reference

    private func householdReference() throws -> DocumentReference {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw HouseholdServiceError.notAuthenticated
        }

        return database
            .collection("households")
            .document(userId)
    }

    // MARK: - Create Household

    func createHousehold(_ household: Household) async throws {
        let reference = try householdReference()

        guard household.id == reference.documentID,
              household.ownerId == reference.documentID else {
            throw HouseholdServiceError.invalidOwner
        }

        // Prevent overwriting an existing household.
        let existingDocument = try await reference.getDocument()

        guard !existingDocument.exists else {
            throw HouseholdServiceError.alreadyExists
        }

        try reference.setData(from: household)
    }

    // MARK: - Fetch Household

    func fetchHousehold() async throws -> Household? {
        let reference = try householdReference()

        let snapshot = try await reference.getDocument()

        guard snapshot.exists else {
            return nil
        }

        return try snapshot.data(as: Household.self)
    }

    // MARK: - Update Household

    func updateHousehold(_ household: Household) async throws {
        let reference = try householdReference()

        guard household.id == reference.documentID,
              household.ownerId == reference.documentID else {
            throw HouseholdServiceError.invalidOwner
        }

        guard try await reference.getDocument().exists else {
            throw HouseholdServiceError.notFound
        }

        try reference.setData(from: household, merge: true)
    }
}

// MARK: - Service Errors

enum HouseholdServiceError: LocalizedError {

    case notAuthenticated
    case invalidOwner
    case alreadyExists
    case notFound

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in before accessing your household."

        case .invalidOwner:
            return "The household does not belong to the signed-in user."

        case .alreadyExists:
            return "A household already exists for this account."

        case .notFound:
            return "No household was found for this account."
        }
    }
}
