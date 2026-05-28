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
    @Published var errorMessage: String?
    
    var canLogin: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !isLoading
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

    var onLoginSuccess: (() -> Void)?
    
    private let authService: AuthServicing

    init(authService: AuthServicing) {
        self.authService = authService
    }
    
   

    func login() async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await authService.login(
                email: email,
                password: password
            )

            isLoading = false
            onLoginSuccess?()

        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}
