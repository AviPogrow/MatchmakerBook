//
//  AuthCoordinator.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/28/26.
//  Copyright © 2026 user. All rights reserved.
//

import UIKit

import UIKit

@MainActor
final class AuthCoordinator {

    private let container: AppContainer
    private let navigationController = UINavigationController()

    var onAuthSuccess: (() -> Void)?

    init(container: AppContainer) {
        self.container = container
    }

    func start() -> UIViewController {
        showWelcome()
        return navigationController
    }

    private func showWelcome() {
        let viewModel = WelcomeViewModel()

        viewModel.onLoginTapped = { [weak self] in
            self?.showLogin()
        }

        viewModel.onSignupTapped = { [weak self] in
            self?.showSignup()
        }

        let welcomeVC = WelcomeHostingController(viewModel: viewModel)

        navigationController.setViewControllers([welcomeVC], animated: false)
    }

    private func showLogin() {
        let viewModel = LoginViewModel(
            authService: container.authService
        )

        viewModel.onLoginSuccess = { [weak self] in
            self?.onAuthSuccess?()
        }

        let loginVC = SwiftUIAuthHostingController(viewModel: viewModel)

        navigationController.pushViewController(loginVC, animated: true)
    }

    private func showSignup() {
        // next step
    }
}
