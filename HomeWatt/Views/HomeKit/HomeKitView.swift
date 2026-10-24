import SwiftUI
import HomeKit


//home kit SDK    integration filesssss /////
struct HomeKitView: View {
    @StateObject private var service = HomeKitService.shared

    var body: some View {
        List {
            Section {
                Text("HomeKit accessories are separate from HomeWatt's simulated appliances. Power and energy are only shown when an accessory exposes those characteristics.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            if !service.isReady { ProgressView("Discovering HomeKit homes…") }
            else if service.homes.isEmpty {
                ContentUnavailableView(
                    "No HomeKit Homes",
                    systemImage: "house.and.flag",
                    description: Text("Create a test home and pair a simulated accessory below.")
                )
            }
            else {
                ForEach(service.homes, id: \.uniqueIdentifier) { home in
                    Section(home.name) {
                        ForEach(home.accessories, id: \.uniqueIdentifier) { accessory in
                            NavigationLink {
                                HomeKitAccessoryView(accessory: accessory)
                            } label: {
                                Text(accessory.name)
                            }
                        }
                    }
                }
            }

            if service.isReady {
                Section {
                    Button {
                        service.addAccessory()
                    } label: {
                        Label(
                            service.isPairingAccessory
                                ? "Opening HomeKit Setup..."
                                : "Add HomeKit Accessory",
                            systemImage: "plus.circle.fill"
                        )
                    }
                    .disabled(service.isPairingAccessory)

                    if service.isPairingAccessory {
                        ProgressView("Opening Apple's pairing sheet...")
                    }
                } header: {
                    Text("Accessory Setup")
                } footer: {
                    Text("For simulator testing, first create an accessory in Apple's HomeKit Accessory Simulator. Apple's pairing flow lets you choose or create a test home when needed.")
                }
            }

            if let error = service.errorMessage { Section { Label(error, systemImage: "exclamationmark.triangle").foregroundStyle(.orange) } }
        }
        .navigationTitle("HomeKit")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    service.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(!service.isReady)
                .accessibilityLabel("Refresh HomeKit accessories")
            }
        }
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
                                .accessibilityHint("Controls the actual HomeKit accessory power state.")
                        } else if let value = characteristic.value {
                            LabeledContent(characteristic.localizedDescription, value: "\(value)")
                        }
                    }
                }
            }
        }
        .navigationTitle(accessory.name)
    }
}
