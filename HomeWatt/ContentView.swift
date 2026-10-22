import SwiftUI
import FirebaseAuth

struct ContentView: View {

    @State private var authViewModel = AuthViewModel()
    @State private var householdViewModel = HouseholdViewModel()

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @EnvironmentObject private var biometricLockManager: BiometricLockManager

    var body: some View {
        ZStack {
            Group {
                if !authViewModel.isAuthenticated {
                    LoginView(authViewModel: authViewModel)

                } else if !householdViewModel.hasLoadedHousehold {
                    ProgressView("Loading your household...")

                } else if householdViewModel.errorMessage != nil
                            && !householdViewModel.hasHousehold {
                    householdErrorView

                } else if !householdViewModel.hasHousehold {
                    HouseholdOnboardingView(
                        householdViewModel: householdViewModel
                    )

                } else {
                    mainApplicationView
                }
            }
            .environment(authViewModel)
            .environment(householdViewModel)
            .task(id: authViewModel.currentUser?.uid) {
                householdViewModel.reset()

                guard authViewModel.isAuthenticated else {
                    return
                }

                await householdViewModel.loadHousehold()
            }

            if biometricLockManager.isLocked {
                BiometricLockView()
                    .ignoresSafeArea()
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { _, isAuthenticated in
            if !isAuthenticated {
                biometricLockManager.reset()
            }
        }
    }

    @ViewBuilder
    private var mainApplicationView: some View {
        if horizontalSizeClass == .regular {
            MainSidebarView()
        } else {
            MainTabView()
        }
    }

    private var householdErrorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Unable to Load Household")
                .font(.title2.bold())

            Text(
                householdViewModel.errorMessage
                ?? "An unexpected error occurred."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await householdViewModel.loadHousehold()
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Sign Out") {
                Task {
                    await authViewModel.logout()
                }
            }
        }
        .padding(24)
    }
}

#Preview {
    ContentView()
}
