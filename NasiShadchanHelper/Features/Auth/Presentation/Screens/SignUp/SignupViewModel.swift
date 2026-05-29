//
//  SignupViewModel.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/28/26.
//  Copyright © 2026 user. All rights reserved.
//
import Foundation

@MainActor
final class SignupViewModel: ObservableObject {
    @Published var selectedImageData: Data?
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    var canSignup: Bool {
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

    var onSignupSuccess: (() -> Void)?

    private let authService: AuthServicing

    init(authService: AuthServicing) {
        self.authService = authService
    }
    func profileImageSelected(_ data: Data) {
        selectedImageData = data
        errorMessage = nil
    }
    func signup() async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await authService.signup(
                email: email,
                password: password
            )

            isLoading = false
            onSignupSuccess?()

        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    }
