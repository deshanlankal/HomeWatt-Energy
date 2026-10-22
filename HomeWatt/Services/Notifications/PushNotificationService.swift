import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import UIKit

/// Bridges APNs and FCM. It stores only the current user's token; push delivery stays server-side.
@MainActor
final class PushNotificationService: NSObject, MessagingDelegate {
    static let shared = PushNotificationService()
    private let database = Firestore.firestore()

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

    func removeCurrentUserToken() async {
        guard let userID = Auth.auth().currentUser?.uid,
              let token = try? await Messaging.messaging().token() else { return }
        do {
            try await database.collection("users").document(userID).collection("fcmTokens").document(token).delete()
        } catch {
            print("Unable to remove FCM token: \(error.localizedDescription)")
        }
    }

    private func store(token: String) async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        do {
            try await database.collection("users").document(userID).collection("fcmTokens").document(token).setData([
                "token": token,
                "platform": "ios",
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)
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
