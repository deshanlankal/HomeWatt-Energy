# HomeWatt deployment configuration

## Apple capabilities

In Xcode, enable **Push Notifications**, **Background Modes → Remote notifications**, **HomeKit**, and the App Group `group.com.deshanlanka.HomeWatt` for the app and Widget extension. Add the generated `.entitlements` files to both targets. Live Activities require the `NSSupportsLiveActivities` Info.plist key and must be tested on iOS 16.1+ hardware.

Create a HomeWatt Widget Extension target in Xcode, select the same App Group, and include `HomeWattWidget/HomeWattWidget.swift` in that target (it is deliberately outside the app target to avoid an extra `@main` entry point). Widget refreshes are constrained by iOS; it is not continuous monitoring.

## Firebase / APNs

Upload an APNs authentication key in Firebase Console → Project settings → Cloud Messaging, enable Push Notifications on the App ID, and use a provisioning profile containing that capability. Deploy functions with `firebase deploy --only functions` from this repository after installing the dependencies in `functions/`. No Admin credential belongs in the iOS app.

Deploy `firestore.rules` through the Firebase CLI or Console after reviewing it. The rules scope household documents, child collections, and FCM tokens to `request.auth.uid`.

## Diagnostics SDK

For a university build, Firebase Crashlytics is the recommended additional diagnostics SDK: add the `FirebaseCrashlytics` SPM product and the run-script integration in Xcode, then call `Crashlytics.crashlytics().setUserID(...)` after Firebase login. This needs no separate paid service or app secret. It is intentionally not linked here because the current Firebase SPM selection does not include Crashlytics and command-line Xcode project mutation cannot resolve it safely without Xcode installed.
