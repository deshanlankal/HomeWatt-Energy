//
//  EnergyReadingService.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-21.
//

import Foundation

//
//  EnergyReadingService.swift
//  HomeWatt
//
import FirebaseAuth
import FirebaseFirestore

enum EnergyReadingServiceError: LocalizedError {
    case notAuthenticated
    case invalidHousehold
    case invalidReading

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to access energy readings."
        case .invalidHousehold:
            return "You cannot access this household."
        case .invalidReading:
            return "The energy reading contains invalid data."
        }
    }
}

@MainActor
final class EnergyReadingService {

    static let shared = EnergyReadingService()

    private let database = Firestore.firestore()

    private init() {}

    private func readingsReference(
        householdId: String
    ) throws -> CollectionReference {

        guard let userId = Auth.auth().currentUser?.uid else {
            throw EnergyReadingServiceError.notAuthenticated
        }

        guard householdId == userId else {
            throw EnergyReadingServiceError.invalidHousehold
        }

        return database
            .collection("households")
            .document(householdId)
            .collection("energyReadings")
    }

    func saveReading(_ reading: EnergyReading) async throws {

        try validate(reading)

        let collection = try readingsReference(
            householdId: reading.householdId
        )

        try collection
            .document(reading.id)
            .setData(from: reading)
    }

    func saveReadings(_ readings: [EnergyReading]) async throws {

        guard !readings.isEmpty else { return }

        // Firestore batches have limits, so use small chunks.
        let chunkSize = 400

        for chunkStart in stride(
            from: 0,
            to: readings.count,
            by: chunkSize
        ) {
            let chunkEnd = min(
                chunkStart + chunkSize,
                readings.count
            )

            let chunk = Array(readings[chunkStart..<chunkEnd])

            let batch = database.batch()

            for reading in chunk {
                try validate(reading)

                let collection = try readingsReference(
                    householdId: reading.householdId
                )

                let reference = collection.document(reading.id)

                try batch.setData(
                    from: reading,
                    forDocument: reference
                )
            }

            try await batch.commit()
        }
    }


    func fetchReadings(
        householdId: String,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [EnergyReading] {

        let collection = try readingsReference(
            householdId: householdId
        )

        guard startDate < endDate else {
            return []
        }

        
        let snapshot = try await collection
            .whereField(
                "intervalStart",
                isGreaterThanOrEqualTo: startDate
            )
            .whereField(
                "intervalStart",
                isLessThan: endDate
            )
            .getDocuments()

        
        return try snapshot.documents
            .map {
                try $0.data(as: EnergyReading.self)
            }
            .sorted {
                $0.intervalStart < $1.intervalStart
            }

    }


    func deleteReading(
        readingId: String,
        householdId: String
    ) async throws {

        guard !readingId.isEmpty,
              !readingId.contains("/") else {
            throw EnergyReadingServiceError.invalidReading
        }

        let collection = try readingsReference(
            householdId: householdId
        )

        try await collection
            .document(readingId)
            .delete()
    }


    private func validate(_ reading: EnergyReading) throws {

        guard !reading.id.isEmpty,
              !reading.id.contains("/"),
              reading.intervalStart < reading.intervalEnd,
              reading.energyKWh.isFinite,
              reading.energyKWh >= 0,
              reading.averagePowerWatts.isFinite,
              reading.averagePowerWatts >= 0,
              reading.source == "simulation" else {
            throw EnergyReadingServiceError.invalidReading
        }
    }
}
