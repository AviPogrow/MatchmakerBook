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
    private let launchCoordinator = AppLaunchCoordinator()

    init(window: UIWindow, container: AppContainer) {
        self.window = window
        self.container = container
    }

    func start(isLoggedIn: Bool = false) {
        let flow = launchCoordinator.start(isLoggedIn: isLoggedIn)

        switch flow {
        case .showLogin:
            showLogin()

        case .showMainApp:
            showMainApp()
        }

        window.makeKeyAndVisible()
    }

    private func showLogin() {
        let viewModel = LoginViewModel(
            authService: container.authService
        )

        let loginVC = SwiftUIAuthHostingController(
            viewModel: viewModel
        )

        window.rootViewController = loginVC
    }

    private func showMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBar = storyboard.instantiateViewController(
            withIdentifier: "MyTabBarController"
        )

        window.rootViewController = tabBar
    }
}
