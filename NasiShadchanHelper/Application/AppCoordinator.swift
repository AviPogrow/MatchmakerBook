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
        let mainTabCoordinator = MainTabCoordinator(
            container: container
        )

        let tabBarController = mainTabCoordinator.start()

        window.rootViewController = tabBarController
    }
}
