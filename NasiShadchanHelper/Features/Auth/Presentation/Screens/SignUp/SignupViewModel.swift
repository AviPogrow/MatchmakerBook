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
    @Published var uploadProgress: Double = 0
    
    private let profileImageUploader: ProfileImageUploading
    
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    var isUploadingImage: Bool {
        uploadProgress > 0 && uploadProgress < 1
    }
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

    init(
        authService: AuthServicing,
        profileImageUploader: ProfileImageUploading
    ) {
        self.authService = authService
        self.profileImageUploader = profileImageUploader
    }
    
    func profileImageSelected(_ data: Data) {
        selectedImageData = data
        errorMessage = nil
    }
    
    func simulateUploadProgress() async {
        uploadProgress = 0

        for step in 1...10 {
            try? await Task.sleep(nanoseconds: 200_000_000)
            uploadProgress = Double(step) / 10.0
        }
    }
    
    func signup() async {
        isLoading = true
        errorMessage = nil
        uploadProgress = 0

        do {
            let user = try await authService.signup(
                email: email,
                password: password
            )

            if let imageData = selectedImageData {
                let imageURL = try await profileImageUploader.uploadProfileImage(
                    data: imageData,
                    userID: user.userID
                )

                print("Uploaded image URL:", imageURL)
            }

            isLoading = false
            uploadProgress = 1
            onSignupSuccess?()

        } catch {
            isLoading = false
            uploadProgress = 0
            errorMessage = error.localizedDescription
        }
    }
    }
