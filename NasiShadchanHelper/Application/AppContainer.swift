//
//  AppContainer.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/22/26.
//  Copyright © 2026 user. All rights reserved.
//
import Foundation

final class AppContainer {

    let authService: AuthServicing

    init() {
        self.authService = FirebaseAuthService()
    }
}
