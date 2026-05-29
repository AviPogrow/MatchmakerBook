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
    
    func signup(email: String, password: String) async throws -> AuthSession {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let user = result?.user else {
                    continuation.resume(throwing: AuthError.unknown)
                    return
                }

                let session = AuthSession(
                    userID: user.uid,
                    email: user.email
                )
                continuation.resume(returning: session)
            }
        }
    }
}
