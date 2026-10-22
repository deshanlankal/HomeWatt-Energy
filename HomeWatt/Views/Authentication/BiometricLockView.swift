import SwiftUI

struct BiometricLockView: View {
    @ObservedObject var manager = BiometricLockManager.shared

    var body: some View {
        ZStack {
            HomeWattTheme.primary.opacity(0.96).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "lock.shield.fill").font(.system(size: 52)).accessibilityHidden(true)
                Text("HomeWatt is Locked").font(.title.bold())
                Text("Use Face ID or Touch ID to access your simulated energy data.")
                    .multilineTextAlignment(.center).foregroundStyle(.white.opacity(0.9))
                Button { Task { await manager.unlock() } } label: {
                    Label("Unlock HomeWatt", systemImage: "faceid")
                }
                .buttonStyle(.borderedProminent).tint(.white).foregroundStyle(HomeWattTheme.primary)
                if let message = manager.availabilityMessage {
                    Text(message).font(.footnote).multilineTextAlignment(.center).foregroundStyle(.white.opacity(0.9))
                }
            }.padding(32).foregroundStyle(.white)
        }
        .task { await manager.unlock() }
    }
}
