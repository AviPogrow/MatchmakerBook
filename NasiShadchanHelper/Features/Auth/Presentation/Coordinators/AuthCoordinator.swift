//
//  AuthCoordinator.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/28/26.
//  Copyright © 2026 user. All rights reserved.
//

import UIKit

@MainActor
final class AuthCoordinator {

    private let container: AppContainer

    var onAuthSuccess: (() -> Void)?

    init(container: AppContainer) {
        self.container = container
    }

    func start() -> UIViewController {

        let viewModel = LoginViewModel(
            authService: container.authService
        )

        viewModel.onLoginSuccess = { [weak self] in
            self?.onAuthSuccess?()
        }

        return SwiftUIAuthHostingController(
            viewModel: viewModel
        )
    }
}
