//
//  WelcomeViewModel.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/28/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation

@MainActor
final class WelcomeViewModel: ObservableObject {

    var onLoginTapped: (() -> Void)?
    var onSignupTapped: (() -> Void)?

    func loginTapped() {
        onLoginTapped?()
    }

    func signupTapped() {
        onSignupTapped?()
    }
}
