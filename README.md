## Examiner / Lecturer Setup and Backend Access

This section explains how an assessor can run HomeWatt, access its Firebase backend, and review the additional integrations used in the project.

### 1. Run HomeWatt in Xcode

1. Download the submitted source-code ZIP or clone the private GitHub repository.
2. Extract the ZIP if applicable.
3. Open `HomeWatt.xcodeproj` in Xcode.
4. Allow Xcode to resolve the Swift Package dependencies.
5. Select the **HomeWatt** application scheme.
6. Choose a compatible iPhone or iPad simulator.
7. Press **Command + R** to build and launch the application.

The application requires an internet connection for Firebase Authentication and cloud-based data operations.

The Firebase iOS configuration file is located at:

`HomeWatt/Resources/GoogleService-Info.plist`

The configured Firebase project is `homewatt-947e6`.

### 2. Access the Firebase Backend

Firebase provides authentication, household and appliance storage, energy-reading persistence, and cloud messaging services.

**Firebase Console:** [https://console.firebase.google.com/](https://console.firebase.google.com/)

**Firebase Project ID:** `homewatt-947e6`

The examiner can inspect the following services, subject to the permissions granted:

- **Authentication:** Registered application users and enabled authentication providers.
- **Cloud Firestore:** Household, appliance, energy-reading, and notification-related collections.
- **Cloud Messaging:** Firebase Cloud Messaging configuration for remote notifications.
- **Cloud Functions:** Deployed server-side notification logic, where available.

The examiner will be invited using their Google account with appropriately restricted Firebase/Google Cloud IAM permissions.

Access to individual Firestore documents depends on the assigned permissions. Console access is separate from application authentication.

### 3. HomeWatt Application Test Account

A dedicated HomeWatt demonstration account can be provided to the examiner through a secure communication channel.

The demonstration account allows the examiner to sign in, create or inspect a test household, manage virtual appliances, generate simulated energy readings, and explore the dashboard and history screens.

Login credentials will not be published in the README, GitHub repository, or final report.

### 4. Sentry Diagnostics

HomeWatt integrates Sentry for optional application error monitoring.

**Sentry Dashboard:** [https://sentry.io/](https://sentry.io/)

The examiner can review the Sentry integration through the submitted demonstration recording, report screenshots, or a live walkthrough.

The current Sentry free-tier account does not provide a separate examiner login. Sentry is optional for normal application operation.

### 5. Advanced iOS Feature Testing

- **WidgetKit:** Run HomeWatt and add a HomeWatt widget from the iOS Home Screen.
- **ActivityKit:** Start a supported Live Activity from the application on a compatible iPhone.
- **HomeKit:** Requires an accessible Apple Home configuration and compatible accessories for real accessory testing.
- **Face ID / Touch ID:** Requires a compatible device or configured simulator.
- **Push Notifications:** Remote notification delivery requires configured APNs, FCM, and the relevant backend services.

All household electricity measurements in HomeWatt are simulated. HomeKit accessory states are separate from simulated energy readings.

### 6. Repository and Final Submission

**GitHub Repository:**

[https://github.com/deshanlankal/HomeWatt-Energy](https://github.com/deshanlankal/HomeWatt-Energy)

**Final Commit SHA:**

`3ef92b8dd73274e5dd82dbef6bf1f98699919475`

**Final Commit URL:**

[https://github.com/deshanlankal/HomeWatt-Energy/commit/3ef92b8dd73274e5dd82dbef6bf1f98699919475](https://github.com/deshanlankal/HomeWatt-Energy/commit/3ef92b8dd73274e5dd82dbef6bf1f98699919475)

The examiner must have access to the private GitHub repository to inspect the submitted commit.

### 7. Security

- No administrator passwords or private service-account keys are included in the repository.
- Firebase client configuration is separate from administrator credentials.
- Firebase access is restricted using authentication, Firestore security rules, and applicable IAM permissions.
- Examiner access and demonstration credentials are shared securely.
- All energy readings are simulated and do not represent real household electricity consumption.
