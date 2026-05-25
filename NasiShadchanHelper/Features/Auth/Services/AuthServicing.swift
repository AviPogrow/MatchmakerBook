//
//  AuthServicing.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/24/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation

protocol AuthServicing {
    func login(email: String, password: String) async throws -> AuthSession
}
