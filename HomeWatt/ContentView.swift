//
//  ContentView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            HStack {
                Text("HomeWatt")
                Text("Energy")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
