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
    
    private var authCoordinator: AuthCoordinator?
    private var mainTabCoordinator: MainTabCoordinator?

    // bootStrap
     //creates an AppCoordinator
    // and a UIWindow
    // and inits the AppCoordinator
    // app coordinator stores them to use later
    // window will be set with rootViewController
    // container will provide authService to init
    // the loginViewModel
    init(window: UIWindow, container: AppContainer) {
        self.window = window
        self.container = container
    }

    // we now use the session manager of the container
    // to check if user is logged in
    func start() {
        if container.sessionManager.isLoggedIn() {
            showMainApp()
        } else {
            showLogin()
        }
    }

    private func showLogin() {

        let coordinator = AuthCoordinator(
            container: container
        )

        coordinator.onAuthSuccess = { [weak self] in
            self?.showMainApp()
        }

        authCoordinator = coordinator

        window.rootViewController = coordinator.start()
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
