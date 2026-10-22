import SwiftUI
import HomeKit

struct HomeKitView: View {
    @StateObject private var service = HomeKitService.shared

    var body: some View {
        List {
            Section {
                Text("HomeKit accessories are separate from HomeWatt's simulated appliances. Power and energy are only shown when an accessory exposes those characteristics.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            if !service.isReady { ProgressView("Discovering HomeKit homes…") }
            else if service.homes.isEmpty { ContentUnavailableView("No HomeKit Homes", systemImage: "house.and.flag", description: Text("Add a home or accessories in Apple's Home app, then return here.")) }
            else {
                ForEach(service.homes, id: \.uniqueIdentifier) { home in
                    Section(home.name) {
                        ForEach(home.accessories, id: \.uniqueIdentifier) { accessory in
                            NavigationLink(accessory.name) { HomeKitAccessoryView(accessory: accessory) }
                        }
                    }
                }
            }
            if let error = service.errorMessage { Section { Label(error, systemImage: "exclamationmark.triangle").foregroundStyle(.orange) } }
        }
        .navigationTitle("HomeKit")
    }
}

private struct HomeKitAccessoryView: View {
    let accessory: HMAccessory
    @StateObject private var service = HomeKitService.shared
    var body: some View {
        List {
            ForEach(accessory.services, id: \.uniqueIdentifier) { serviceItem in
                Section(serviceItem.name) {
                    ForEach(serviceItem.characteristics, id: \.uniqueIdentifier) { characteristic in
                        if characteristic.characteristicType == HMCharacteristicTypePowerState {
                            Toggle("Power", isOn: Binding(get: { (characteristic.value as? Bool) ?? false }, set: { _ in Task { await service.toggle(characteristic) } }))
                        } else if let value = characteristic.value {
                            LabeledContent(characteristic.localizedDescription, value: "\(value)")
                        }
                    }
                }
            }
        }.navigationTitle(accessory.name)
    }
}
