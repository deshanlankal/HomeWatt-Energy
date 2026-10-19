//
//  HomeWattTheme.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-19.
//

import Foundation

import SwiftUI

enum HomeWattTheme {

    // MARK: - Brand Colors

    static let primary = Color(
        red: 0.10,
        green: 0.62,
        blue: 0.42
    )

    static let primaryDark = Color(
        red: 0.05,
        green: 0.40,
        blue: 0.28
    )

    static let accent = Color(
        red: 0.98,
        green: 0.72,
        blue: 0.24
    )

    // MARK: - Background Colors

    static let background = Color(
        uiColor: .systemGroupedBackground
    )

    static let cardBackground = Color(
        uiColor: .secondarySystemGroupedBackground
    )

    // MARK: - Text Colors

    static let textPrimary = Color.primary

    static let textSecondary = Color.secondary

    // MARK: - Energy Status Colors

    static let normalEnergy = Color.green

    static let mediumEnergy = Color.orange

    static let highEnergy = Color.red

    // MARK: - Layout

    static let cornerRadius: CGFloat = 16

    static let spacing: CGFloat = 16

    static let horizontalPadding: CGFloat = 20
}

