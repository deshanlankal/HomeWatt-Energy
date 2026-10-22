//
//  NotificationService.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-22.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationService {

    static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Request Permission

    func requestPermission() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
        } catch {
            print("Notification permission error: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Check Permission

    func notificationsEnabled() async -> Bool {
        let settings = await notificationCenter.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }

    // MARK: - High Energy Notification

    func sendHighEnergyAlert(
        currentPowerWatts: Double,
        thresholdWatts: Double
    ) async -> Bool {

        guard currentPowerWatts.isFinite,
              thresholdWatts.isFinite,
              thresholdWatts > 0,
              currentPowerWatts > thresholdWatts else {
            return false
        }

        guard await notificationsEnabled() else {
            return false
        }

        let content = UNMutableNotificationContent()

        content.title = "High Energy Usage Detected"

        content.body = String(
            format: "Your simulated power consumption is %.0f W, exceeding your household threshold of %.0f W.",
            currentPowerWatts,
            thresholdWatts
        )

        content.sound = .default
        content.userInfo = ["type": "highEnergy", "destination": "dashboard"]

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(
                timeInterval: 2,
                repeats: false
            )
        )

        do {
            try await notificationCenter.add(request)
            return true
        } catch {
            print("Unable to schedule notification: \(error.localizedDescription)")
            return false
        }
    }
}
