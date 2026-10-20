//
//  AuthenticationService.swift
//  HomeWatt
//
//  Created by Deshan Lanka on 2026-10-20.
//

import Foundation

import Foundation
import FirebaseAuth

@MainActor
final class AuthenticationService {

    static let shared = AuthenticationService()

    private init() {}

    // MARK: - Register

    func register(
        email: String,
        password: String
    ) async throws -> User {

        let result = try await Auth.auth()
            .createUser(
                withEmail: email,
                password: password
            )

        return result.user
    }

    // MARK: - Login

    func login(
        email: String,
        password: String
    ) async throws -> User {

        let result = try await Auth.auth()
            .signIn(
                withEmail: email,
                password: password
            )

        return result.user
    }

    // MARK: - Current User

    var currentUser: User? {
        Auth.auth().currentUser
    }

    // MARK: - Password Reset

    func resetPassword(email: String) async throws {
        try await Auth.auth()
            .sendPasswordReset(withEmail: email)
    }

    // MARK: - Logout

    func logout() throws {
        try Auth.auth().signOut()
    }
}
