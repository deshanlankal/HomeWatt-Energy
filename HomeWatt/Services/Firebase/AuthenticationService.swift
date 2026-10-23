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


    var currentUser: User? {
        Auth.auth().currentUser
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth()
            .sendPasswordReset(withEmail: email)
    }

    func logout() throws {
        try Auth.auth().signOut()
    }
}
