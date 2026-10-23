import Foundation
import Combine
import LocalAuthentication

@MainActor
final class BiometricLockManager: ObservableObject {
    static let shared = BiometricLockManager()

    @Published private(set) var isLocked = false
    @Published private(set) var availabilityMessage: String?

    private let preferenceKey = "homewatt.biometricLockEnabled"
    private var authenticationInProgress = false

    var biometricLockEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: preferenceKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: preferenceKey)
            if !newValue { isLocked = false }
        }
    }

    private init() {}

    func lockIfNeeded() {
        guard biometricLockEnabled, !authenticationInProgress else { return }
        isLocked = true
    }

    func handleAppForeground() {
        guard biometricLockEnabled else { return }
        isLocked = true
    }

    func unlock() async {
        guard biometricLockEnabled else { isLocked = false; return }
        guard !authenticationInProgress else { return }
        authenticationInProgress = true
        availabilityMessage = nil
        defer { authenticationInProgress = false }

        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            availabilityMessage = biometricErrorMessage(error)
            return
        }

        do {
            let reason = "Unlock HomeWatt to view your simulated household energy data."
            try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            isLocked = false
        } catch {
            availabilityMessage = biometricErrorMessage(error as NSError)
        }
    }

    func enableAfterVerification() async -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            availabilityMessage = biometricErrorMessage(error)
            return false
        }
        do {
            try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Enable secure HomeWatt app unlock.")
            biometricLockEnabled = true
            availabilityMessage = nil
            return true
        } catch {
            availabilityMessage = biometricErrorMessage(error as NSError)
            return false
        }
    }

    func reset() {
        isLocked = false
        availabilityMessage = nil
        authenticationInProgress = false
    }

    private func biometricErrorMessage(_ error: NSError?) -> String {
        guard let error else { return "Biometric authentication is unavailable on this device." }
        switch LAError.Code(rawValue: error.code) {
        case .biometryNotEnrolled: return "Set up Face ID or Touch ID in Settings to enable app unlock."
        case .biometryLockout: return "Biometrics are locked. Unlock your device and try again."
        case .userCancel, .appCancel, .systemCancel: return "Authentication was cancelled."
        case .authenticationFailed: return "Face ID or Touch ID did not match."
        default: return "Biometric authentication is unavailable: \(error.localizedDescription)"
        }
    }
}

