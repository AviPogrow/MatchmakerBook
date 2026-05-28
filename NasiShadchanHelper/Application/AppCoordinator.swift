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
        // get the auth service from container
        // init a LoginViewModel with authService
        // we then will use LoginViewModel
        // to init the LoginView
        let viewModel = LoginViewModel(
            authService: container.authService
        )
        // set the closure on the onLoginSuccesss
        // callback
        viewModel.onLoginSuccess = { [weak self] in
            self?.showMainApp()
        }

        // inject the view model into the init method
        // of hostingController
        // that then injects it into the loginView
        // which is the rootView
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
