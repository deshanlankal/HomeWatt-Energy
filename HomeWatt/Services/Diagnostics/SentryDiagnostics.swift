import Foundation
import Sentry

/// Optional crash and hang diagnostics. It does nothing until SentryDSN is configured.
enum SentryDiagnostics {
    static func configure() {
        guard let dsn = Bundle.main.object(forInfoDictionaryKey: "SentryDSN") as? String,
              !dsn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        SentrySDK.start { options in
            options.dsn = dsn
            options.sendDefaultPii = false
            options.enableAppHangTracking = true
        }
    }

    static func setAuthenticatedUser(id: String?) {
        guard let id else { SentrySDK.setUser(nil); return }
        SentrySDK.setUser(User(userId: id))
    }
}
