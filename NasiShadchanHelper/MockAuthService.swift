//
//  MockAuthService.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/8/26.
//  Copyright © 2026 user. All rights reserved.
//
import Foundation
final class MockAuthService: AuthService {

    func login(
        email: String,
        password: String,
        completion: @escaping (Result<AuthSession, AuthError>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(
                .success(
                    AuthSession(
                        userID: "mock-user-id",
                        email: email
                    )
                )
            )
        }
    }
}
