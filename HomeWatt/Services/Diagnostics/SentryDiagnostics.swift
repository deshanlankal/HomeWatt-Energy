// NOTE: Make sure the Info.plist file in your main app target contains a key 'SENTRY_DSN' with your Sentry DSN string. If it's missing or incorrect, Sentry diagnostics will not work and configuration will print a warning.

import Foundation
import Sentry

enum SentryDiagnostics {

    static func configure() {

        guard let dsn = Bundle.main.object(
            forInfoDictionaryKey: "SENTRY_DSN"
            // Make sure that SENTRY_DSN is added to your Info.plist with the correct DSN string from Sentry.
        ) as? String,
        !dsn.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty else {
            print("Sentry: DSN is not configured.")
            return
        }

        SentrySDK.start { options in
            options.dsn = dsn
            options.sendDefaultPii = false
            options.enableAppHangTracking = true

            #if DEBUG
            options.debug = true
            #endif
        }
    }

    static func setAuthenticatedUser(id: String?) {
        guard let id else {
            SentrySDK.setUser(nil)
            return
        }

        SentrySDK.setUser(User(userId: id))
    }

/////////////// test is the sentry works /////////////////
    static func sendTestEvent() {
        #if DEBUG
        SentrySDK.capture(
            message: "HomeWatt iOS Sentry integration test"
        )

        print("Sentry: Test event submitted to SDK.")
        #endif
    }

}
