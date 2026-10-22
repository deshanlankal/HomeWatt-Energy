//
//  HomeWattApp.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-01.
//

import SwiftUI
import FirebaseCore
import UserNotifications
import UIKit

@main
struct HomeWattApp: App {

    // MARK: - App Initialization

    @State private var scenePhase: ScenePhase = .inactive
    @UIApplicationDelegateAdaptor(HomeWattAppDelegate.self) private var appDelegate
    @StateObject private var biometricLockManager = BiometricLockManager.shared
    @StateObject private var notificationNavigation = NotificationNavigationState.shared

    init() {

        // Configure Firebase
        FirebaseApp.configure()
        SentryDiagnostics.configure()

        // Register notification delegate
        UNUserNotificationCenter.current().delegate =
            NotificationDelegateHolder.shared.delegate
    }

    // MARK: - Main App Window

    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(biometricLockManager)
            .environmentObject(notificationNavigation)
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .active:
                    biometricLockManager.handleAppForeground()
                case .background, .inactive:
                    biometricLockManager.lockIfNeeded()
                @unknown default:
                    break
                }
            }
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
