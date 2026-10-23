import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import FirebaseFunctions
import UIKit

@MainActor
final class PushNotificationService: NSObject, MessagingDelegate {
    static let shared = PushNotificationService()
    private let database = Firestore.firestore()
    private let functions = Functions.functions()

    private override init() { super.init() }

    func configure() {
        Messaging.messaging().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
    }

    func setAPNSToken(_ token: Data) {
        Messaging.messaging().apnsToken = token
    }

    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        Task { @MainActor in await self.store(token: fcmToken) }
    }

    func refreshTokenAssociation() async {
        guard let token = try? await Messaging.messaging().token() else { return }
        await store(token: token)
    }

    func updateHighEnergyPreference(enabled: Bool) async {
        guard let token = try? await Messaging.messaging().token() else { return }
        await store(token: token, highEnergyAlertsEnabled: enabled)
    }

    /// Sends a remote alert to the user's *other* enabled devices. The current device receives the local alert.
    func sendHighEnergyAlertToOtherDevices(currentPowerWatts: Double, thresholdWatts: Double) async {
        guard let sourceToken = try? await Messaging.messaging().token() else { return }
        do {
            _ = try await functions.httpsCallable("sendHighEnergyPush").call([
                "currentPowerWatts": currentPowerWatts,
                "thresholdWatts": thresholdWatts,
                "sourceToken": sourceToken
            ])
        } catch {
            print("Remote high-energy notification was not sent: \(error.localizedDescription)")
        }
    }

    func removeCurrentUserToken() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let token = (try? await Messaging.messaging().token())
            ?? defaults.string(forKey: associatedTokenKey(userID: userID))

        guard let token else { return }

        await removeToken(token, for: userID)
    }

    private let defaults = UserDefaults.standard

    private func associatedTokenKey(userID: String) -> String {
        "homewatt.fcmToken.\(userID)"
    }

    private func removeToken(_ token: String, for userID: String) async {
        do {
            try await database.collection("users").document(userID).collection("fcmTokens").document(token).delete()
            defaults.removeObject(forKey: associatedTokenKey(userID: userID))
        } catch {
            print("Unable to remove FCM token: \(error.localizedDescription)")
        }
    }

    private func store(token: String, highEnergyAlertsEnabled: Bool = UserDefaults.standard.object(forKey: "homewatt.highEnergyAlertsEnabled") as? Bool ?? true) async {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let tokenKey = associatedTokenKey(userID: userID)
        if let previousToken = defaults.string(forKey: tokenKey),
           previousToken != token {
            await removeToken(previousToken, for: userID)
        }

        do {
            try await database.collection("users").document(userID).collection("fcmTokens").document(token).setData([
                "token": token,
                "platform": "ios",
                "highEnergyAlertsEnabled": highEnergyAlertsEnabled,
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)
            defaults.set(token, forKey: tokenKey)
        } catch { print("Unable to store FCM token: \(error.localizedDescription)") }
    }
}

final class HomeWattAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        PushNotificationService.shared.configure()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationService.shared.setAPNSToken(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error.localizedDescription)")
    }
}
