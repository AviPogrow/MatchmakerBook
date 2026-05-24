//
//  Untitled.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/8/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation
@MainActor
final class LoginViewModel: ObservableObject {

 
      @Published var email = ""
      @Published var password = ""
      @Published var isLoading = false
      @Published var session: AuthSession?
      @Published var errorMessage: String?

    private let authService: AuthServicing

    init(authService: AuthServicing) {
          self.authService = authService
      }

    var canLogin: Bool {
           !email.isEmpty && !password.isEmpty
       }

    var validationMessage: String? {

        if email.isEmpty {
            return "Email is required"
        }

        if password.isEmpty {
            return "Password is required"
        }

        return nil
    }
 /*
    func login() {

        guard canLogin else {
            return
        }

        isLoading = true

        authService.login(
            email: email,
            password: password
        ) { [weak self] result in

            guard let self else { return }

            self.isLoading = false

            switch result {
            case .success(let session):
                self.session = session
                self.errorMessage = nil
                print("✅ Login success")

            case .failure(let error):
                self.session = nil
                self.errorMessage = error.localizedDescription
                print("❌ Login failed: \(error.localizedDescription)")
            }
        }
    }
  */
    func login() async {
        guard canLogin else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let session =
            try await authService.login(
                email: email,
                password: password)
            self.session = session
            self.errorMessage = nil
            print("✅ Login success")
        } catch {
            self.session = nil
            self.errorMessage = error.localizedDescription
            print("❌ Login failed: \(error.localizedDescription)")
        }
        isLoading = false
    }
        
}

    

