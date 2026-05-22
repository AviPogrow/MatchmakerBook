//
//  LoginViewModelTests.swift
//  NasiShadchanHelperTests
//
//  Created by Avi Pogrow on 5/9/26.
//  Copyright © 2026 user. All rights reserved.
//

import XCTest
@testable import NasiShadchanHelper

final class LoginViewModelTests: XCTestCase {
    
    final class TestAuthService: AuthService {
        var loginWasCalled = false
        var receivedEmail: String?
        var receivedPassword: String?

        var completion: ((Result<AuthSession, AuthError>) -> Void)?

        func login(
            email: String,
            password: String,
            completion: @escaping (Result<AuthSession, AuthError>) -> Void
        ) {
            loginWasCalled = true
            receivedEmail = email
            receivedPassword = password
            self.completion = completion
        }
    }

    func testCanLoginIsFalseWhenEmailAndPasswordAreEmpty() {
        // Given
        let viewModel = LoginViewModel()

        // When
        viewModel.email = ""
        viewModel.password = ""

        // Then
        XCTAssertFalse(viewModel.canLogin)
    }
    
    func testCanLoginIsTrueWhenEmailAndPasswordAreFilled() {
        // Given
        let viewModel = LoginViewModel()

        // When
        viewModel.email = "avi@example.com"
        viewModel.password = "secret123"

        // Then
        XCTAssertTrue(viewModel.canLogin)
    }
    
    func testValidationMessageReturnsEmailRequiredWhenEmailIsEmpty() {
        // Given
        let viewModel = LoginViewModel()

        // When
        viewModel.email = ""
        viewModel.password = "secret123"

        // Then
        XCTAssertEqual(viewModel.validationMessage, "Email is required")
    }
    
    func testValidationMessageReturnsPasswordRequiredWhenPasswordIsEmpty() {
        // Given
        let viewModel = LoginViewModel()

        // When
        viewModel.email = "avi@example.com"
        viewModel.password = ""

        // Then
        XCTAssertEqual(viewModel.validationMessage, "Password is required")
    }
    
    func testLoginCallsAuthServiceWithEmailAndPassword() {
        // Given
        let authService = TestAuthService()
        let viewModel = LoginViewModel(authService: authService)

        viewModel.email = "avi@example.com"
        viewModel.password = "secret123"

        // When
        viewModel.login()

        // Then
        XCTAssertTrue(authService.loginWasCalled)
        XCTAssertEqual(authService.receivedEmail, "avi@example.com")
        XCTAssertEqual(authService.receivedPassword, "secret123")
    }
    
    func testLoginSetsLoadingTrueThenFalseAfterCompletion() {
        // Given
        let authService = TestAuthService()
        let viewModel = LoginViewModel(authService: authService)

        viewModel.email = "avi@example.com"
        viewModel.password = "secret123"

        // When
        viewModel.login()

        // Immediately after login starts
        XCTAssertTrue(viewModel.isLoading)

        // Simulate async completion
        authService.completion?(
            .success(AuthSession(userID: "123", email: "avi@example.com"))
        )

        // Then
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoginSuccessSetsSession() {
        // Given
        let authService = TestAuthService()
        let viewModel = LoginViewModel(authService: authService)

        viewModel.email = "avi@example.com"
        viewModel.password = "secret123"

        let expectedSession = AuthSession(
            userID: "123",
            email: "avi@example.com"
        )

        // When
        viewModel.login()

        authService.completion?(.success(expectedSession))

        // Then
        XCTAssertEqual(viewModel.session, expectedSession)
        XCTAssertNil(viewModel.errorMessage)
    }
    
}

