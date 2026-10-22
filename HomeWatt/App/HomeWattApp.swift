
//
//  HomeWattApp.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-01.
//

import SwiftUI
import FirebaseCore
import UserNotifications

@main
struct HomeWattApp: App {

    // MARK: - App Initialization

    init() {

        // Configure Firebase
        FirebaseApp.configure()

        // Register notification delegate
        UNUserNotificationCenter.current().delegate =
            NotificationDelegateHolder.shared.delegate
    }

    // MARK: - Main App Window

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Notification Delegate Holder

@MainActor
final class NotificationDelegateHolder {

    static let shared = NotificationDelegateHolder()

    let delegate = NotificationDelegate()

    private init() {}
}
