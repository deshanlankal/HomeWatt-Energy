//
//  LoginView.swift
//  HomeWatt
//

import SwiftUI

struct LoginView: View {

    let authViewModel: AuthViewModel

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var email = ""
    @State private var password = ""
    @State private var showRegistration = false
    @State private var showPasswordReset = false

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                if horizontalSizeClass == .regular && proxy.size.width >= 700 {
                    iPadLayout(totalWidth: proxy.size.width)
                } else {
                    compactLayout
                }
            }
            .background(HomeWattTheme.background)
            .navigationDestination(isPresented: $showRegistration) {
                RegisterView(authViewModel: authViewModel)
            }
            .navigationDestination(isPresented: $showPasswordReset) {
                ForgotPasswordView(authViewModel: authViewModel)
            }
        }
    }

    private var compactLayout: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(HomeWattTheme.primary)
                    .padding(.top, 50)

                VStack(spacing: 8) {
                    Text("Welcome to HomeWatt")
                        .font(.title.bold())

                    Text("Sign in to manage your home energy")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                signInForm
            }
            .padding(24)
            .frame(maxWidth: 420)
            .frame(maxWidth: .infinity)
        }
    }

    private func iPadLayout(totalWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            iPadWelcomePanel
                .frame(width: totalWidth * 0.43)
                .frame(maxHeight: .infinity)
                .background(iPadWelcomeBackground)

            VStack {
                VStack(alignment: .leading, spacing: 30) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("HomeWatt", systemImage: "bolt.circle.fill")
                            .font(.headline)
                            .foregroundStyle(HomeWattTheme.primary)

                        Text("Welcome back")
                            .font(.system(size: 34, weight: .bold, design: .rounded))

                        Text("Sign in to view your simulated household energy insights.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    signInForm
                }
                .padding(32)
                .frame(maxWidth: 480, alignment: .leading)
                .background(HomeWattTheme.cardBackground, in: RoundedRectangle(cornerRadius: 28))
                .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(24)
        }
    }

    private var iPadWelcomePanel: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()

            Image(systemName: "bolt.circle.fill")
                .font(.system(size: 96))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)

            Text("Energy clarity\nfor your home.")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Track virtual appliances, understand simulated electricity usage, and keep your estimated monthly cost in view.")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 14) {
                featureLabel("Simulated energy insights", icon: "chart.line.uptrend.xyaxis")
                featureLabel("Smart high-energy alerts", icon: "bolt.badge.clock")
                featureLabel("Widgets and Live Activity", icon: "rectangle.3.group")
            }
            .padding(.top, 12)

            Spacer()

            Text("All energy readings in HomeWatt are simulated estimates.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.68))
        }
        .padding(56)
        .accessibilityElement(children: .combine)
    }

    private var iPadWelcomeBackground: some View {
        LinearGradient(
            colors: [HomeWattTheme.primaryDark, HomeWattTheme.primary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func featureLabel(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .foregroundStyle(.white)
    }

    private var signInForm: some View {
        VStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text("Email address")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                TextField("you@example.com", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .frame(minHeight: 44)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text("Password")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                SecureField("Enter your password", text: $password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
                    .frame(minHeight: 44)
            }

            Button("Forgot password?") {
                showPasswordReset = true
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            if let error = authViewModel.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task {
                    await authViewModel.login(
                        email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                        password: password
                    )
                }
            } label: {
                if authViewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(HomeWattTheme.primary)
            .controlSize(.large)
            .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)

            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .foregroundStyle(.secondary)
                Button("Sign Up") {
                    showRegistration = true
                }
                .fontWeight(.semibold)
                .disabled(authViewModel.isLoading)
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
