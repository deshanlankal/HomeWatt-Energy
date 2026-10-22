//
//  AppDestination.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-19.
//

import Foundation

import SwiftUI

enum AppDestination: String, CaseIterable, Identifiable {
    case dashboard
    case devices
    case history
    case homeKit
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .devices: "Devices"
        case .history: "History"
        case .homeKit: "HomeKit"
        case .settings: "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .dashboard: "house.fill"
        case .devices: "powerplug.fill"
        case .history: "chart.bar.fill"
        case .homeKit: "homekit"
        case .settings: "gearshape.fill"
        }
    }
}
