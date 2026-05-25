//
//  Untitled.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/8/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthService: AuthServicing {

    func login(
        email: String,
        password: String
    ) async throws -> AuthSession {

        let result = try await Auth.auth().signIn(
            withEmail: email,
            password: password
        )

        let user = result.user

        return AuthSession(
            userID: user.uid,
            email: user.email
        )
    }
    func logout() throws {
        try Auth.auth().signOut()
    }
}
