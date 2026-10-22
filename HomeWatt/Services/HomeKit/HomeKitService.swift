import Foundation
import Combine
import HomeKit

@MainActor
final class HomeKitService: NSObject, ObservableObject, HMHomeManagerDelegate {
    static let shared = HomeKitService()
    @Published private(set) var homes: [HMHome] = []
    @Published private(set) var isReady = false
    @Published private(set) var errorMessage: String?
    private let manager = HMHomeManager()

    override init() { super.init(); manager.delegate = self }

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        homes = manager.homes
        isReady = true
    }

    func homeManager(_ manager: HMHomeManager, didUpdateAuthorization status: HMHomeManagerAuthorizationStatus) {
        if status == .restricted || status == .determined { errorMessage = "HomeKit access is unavailable. Check Home access in iOS Settings." }
    }

    func toggle(_ characteristic: HMCharacteristic) async {
        guard characteristic.properties.contains(HMCharacteristicPropertyWritable) else { return }
        do {
            let value = (characteristic.value as? Bool) != true
            try await characteristic.writeValue(value)
        } catch { errorMessage = error.localizedDescription }
    }
}
