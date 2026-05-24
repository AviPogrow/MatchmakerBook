//
//  AppBootstrapper.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/24/26.
//  Copyright © 2026 user. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

final class AppBootstrapper {

    private var appCoordinator: AppCoordinator?

    init() {
        configureEarlyInfrastructure()
    }

    @MainActor
    func bootstrap(
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        IQKeyboardManager.shared.enable = true

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.overrideUserInterfaceStyle = .light

        let container = AppContainer()

        let coordinator = AppCoordinator(
            window: window,
            container: container
        )

        self.appCoordinator = coordinator

        coordinator.start()
    }

    private func configureEarlyInfrastructure() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        Database.database().isPersistenceEnabled = true
    }
}
