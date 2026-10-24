import Foundation
import Combine
import HomeKit

@MainActor
final class HomeKitService: NSObject, ObservableObject, HMHomeManagerDelegate {
    static let shared = HomeKitService()
    @Published private(set) var homes: [HMHome] = []
    @Published private(set) var isReady = false
    @Published private(set) var isPairingAccessory = false
    @Published private(set) var errorMessage: String?
    private let manager = HMHomeManager()
    private let accessorySetupManager = HMAccessorySetupManager()

    override init() { super.init(); manager.delegate = self }

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        homes = manager.homes
        isReady = true
    }

    func refresh() {
        homes = manager.homes
        errorMessage = nil
    }

    func homeManager(_ manager: HMHomeManager, didUpdateAuthorization status: HMHomeManagerAuthorizationStatus) {
        if status == .restricted {
            errorMessage = "HomeKit access is unavailable. Check Home access in iOS Settings."
        }
    }

    /// Opens Apple's current HomeKit pairing sheet. With no existing home, the
    /// system pairing flow lets the person choose or create a test home.
    func addAccessory() {
        guard isReady else {
            errorMessage = "HomeKit is still loading. Please try again shortly."
            return
        }

        errorMessage = nil
        isPairingAccessory = true

        let request = HMAccessorySetupRequest()
        if let home = homes.first {
            request.homeUniqueIdentifier = home.uniqueIdentifier
        }

        accessorySetupManager.performAccessorySetup(using: request) { [weak self] _, error in
            DispatchQueue.main.async {
                guard let self else { return }

                self.isPairingAccessory = false

                if let error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.refresh()
                }
            }
        }
    }

    func toggle(_ characteristic: HMCharacteristic) async {
        guard characteristic.properties.contains(HMCharacteristicPropertyWritable) else { return }
        do {
            let value = (characteristic.value as? Bool) != true
            try await characteristic.writeValue(value)
        } catch { errorMessage = error.localizedDescription }
    }
}
