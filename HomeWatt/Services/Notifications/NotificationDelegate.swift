//
//  NotificationDelegate.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-22.
//

import Foundation
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {

        return [.banner, .list, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        await MainActor.run {
            NotificationNavigationState.shared.route(userInfo: response.notification.request.content.userInfo)
        }
    }
}
