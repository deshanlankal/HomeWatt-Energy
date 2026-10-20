//
//  ForgotPasswordView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-20.
//

import Foundation

import SwiftUI

struct ForgotPasswordView: View {

    let authViewModel: AuthViewModel

    @State private var email = ""
    @State private var emailSent = false

    var body: some View {
        VStack(spacing: 20) {

            Image(systemName: "envelope.badge.shield.half.filled")
                .font(.system(size: 60))
                .foregroundStyle(HomeWattTheme.primary)

            Text("Reset Password")
                .font(.title.bold())

            Text("Enter your email address to request a password reset link.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            TextField("Email address", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            if emailSent {
                Label(
                    "If an account exists for this email, you'll receive reset instructions.",
                    systemImage: "checkmark.circle.fill"
                )
                .foregroundStyle(HomeWattTheme.primary)
                .font(.footnote)
            }

            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Button {
                Task {
                    let success = await authViewModel.resetPassword(
                        email: email.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                    )
                    emailSent = success
                }
            } label: {
                if authViewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Send Reset Email")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(HomeWattTheme.primary)
            .disabled(authViewModel.isLoading || email.isEmpty)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: 420)
        .frame(maxWidth: .infinity)
        .navigationTitle("Forgot Password")
        .navigationBarTitleDisplayMode(.inline)
    }
}
