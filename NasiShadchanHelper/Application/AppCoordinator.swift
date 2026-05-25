//
//  AppCoordinator.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/22/26.
//  Copyright © 2026 user. All rights reserved.
//
import UIKit
import SwiftUI

@MainActor
final class AppCoordinator {

    private let window: UIWindow
    private let container: AppContainer
    
    private var mainTabCoordinator: MainTabCoordinator?

    init(window: UIWindow, container: AppContainer) {
        self.window = window
        self.container = container
    }

    func start() {
        if container.sessionManager.isLoggedIn() {
            showMainApp()
        } else {
            showLogin()
        }
    }

    private func showLogin() {
        // get the auth service from container
        // inject it into the LoginViewModel
    
        let viewModel = LoginViewModel(
            authService: container.authService
        )
        
        viewModel.onLoginSuccess = { [weak self] in
            self?.showMainApp()
        }

        let loginVC = SwiftUIAuthHostingController(
            viewModel: viewModel
        )

        window.rootViewController = loginVC
        window.makeKeyAndVisible()
    }

    private func showMainApp() {
        let coordinator = MainTabCoordinator(container: container)

        coordinator.onLogout = { [weak self] in
            self?.showLogin()
        }

        mainTabCoordinator = coordinator
        window.rootViewController = coordinator.start()
        window.makeKeyAndVisible()
    }
}
