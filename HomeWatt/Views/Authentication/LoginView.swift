//
//  LoginView.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-20.
//

import Foundation

import SwiftUI

struct LoginView: View {

    let authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var showRegistration = false
    @State private var showPasswordReset = false

    var body: some View {
        NavigationStack {
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

                    VStack(spacing: 16) {

                        TextField("Email address", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)

                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .textFieldStyle(.roundedBorder)

                        Button("Forgot password?") {
                            showPasswordReset = true
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    }

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task {
                            await authViewModel.login(
                                email: email.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                ),
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
                    .disabled(
                        authViewModel.isLoading ||
                        email.isEmpty ||
                        password.isEmpty
                    )

                    Button("Don't have an account? Sign Up") {
                        showRegistration = true
                    }
                    .disabled(authViewModel.isLoading)

                }
                .padding(24)
                .frame(maxWidth: 420)
                .frame(maxWidth: .infinity)
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
}
