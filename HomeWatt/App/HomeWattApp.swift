//
//  HomeWattApp.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-01.
//

import SwiftUI
import FirebaseCore

@main
struct HomeWattApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
