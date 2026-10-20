//
//  RegisterView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-20.
//

import Foundation

import SwiftUI

struct RegisterView: View {

    let authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var validationError: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 60))
                    .foregroundStyle(HomeWattTheme.primary)

                Text("Create Account")
                    .font(.largeTitle.bold())

                Text("Start monitoring your home's energy")
                    .foregroundStyle(.secondary)

                TextField("Email address", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                    .textFieldStyle(.roundedBorder)

                SecureField(
                    "Confirm password",
                    text: $confirmPassword
                )
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)

                if let error = validationError
                    ?? authViewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                Button {
                    register()
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Create Account")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(HomeWattTheme.primary)
                .disabled(authViewModel.isLoading)

                Text("Your energy data will be simulated for demonstration purposes.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

            }
            .padding(24)
            .frame(maxWidth: 420)
            .frame(maxWidth: .infinity)
        }
        .background(HomeWattTheme.background)
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func register() {
        validationError = nil

        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard cleanEmail.contains("@"),
              cleanEmail.contains(".") else {
            validationError = "Enter a valid email address."
            return
        }

        guard password.count >= 8 else {
            validationError = "Password must contain at least 8 characters."
            return
        }

        guard password == confirmPassword else {
            validationError = "Passwords do not match."
            return
        }

        Task {
            await authViewModel.register(
                email: cleanEmail,
                password: password
            )
        }
    }
}
