//
//  Untitled.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/8/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation

protocol AuthService {
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<AuthSession, AuthError>) -> Void
    )
}
