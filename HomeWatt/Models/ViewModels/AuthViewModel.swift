//
//  AuthViewModel.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-20.
//

import Foundation

import Foundation
import FirebaseAuth
import Observation

@MainActor
@Observable
final class AuthViewModel {

    private let authService = AuthenticationService.shared

    private(set) var currentUser: User?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private var authListener: AuthStateDidChangeListenerHandle?

    var isAuthenticated: Bool {
        currentUser != nil
    }

    init() {
        currentUser = authService.currentUser

        authListener = Auth.auth().addStateDidChangeListener {
            [weak self] _, user in

            Task { @MainActor in
                self?.currentUser = user
            }
        }
    }

    // MARK: - Registration

    func register(
        email: String,
        password: String
    ) async -> Bool {

        await performAuthentication {
            try await self.authService.register(
                email: email,
                password: password
            )
        }
    }

    // MARK: - Login

    func login(
        email: String,
        password: String
    ) async -> Bool {

        await performAuthentication {
            try await self.authService.login(
                email: email,
                password: password
            )
        }
    }

    // MARK: - Password Reset

    func resetPassword(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            try await authService.resetPassword(email: email)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Logout

    func logout() {
        do {
            try authService.logout()
            currentUser = nil
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Shared Authentication Logic

    private func performAuthentication(
        _ operation: () async throws -> User
    ) async -> Bool {

        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let user = try await operation()
            currentUser = user
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
