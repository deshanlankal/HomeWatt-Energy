import Foundation
import Combine

@MainActor
final class NotificationNavigationState: ObservableObject {
    static let shared = NotificationNavigationState()
    @Published var requestedDestination: AppDestination?

    func route(userInfo: [AnyHashable: Any]) {
        guard let rawValue = userInfo["destination"] as? String,
              let destination = AppDestination(rawValue: rawValue) else { return }
        requestedDestination = destination
    }
}
