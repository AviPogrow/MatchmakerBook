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

    // when app delegate is initialized it calls
    //  the init method on the appBootStrapper
    init() {
        configureEarlyInfrastructure()
    }

    @MainActor
    func bootstrap(
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        IQKeyboardManager.shared.enable = true

        //1. init a window object and configure it
        // to ignore dark mode
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.overrideUserInterfaceStyle = .light

        
        //2.  init an app container object
        let container = AppContainer()

        //3. pass the window and container
        // and inject them into a new app coordinator object
        let coordinator = AppCoordinator(
            window: window,
            container: container
        )

        // save the appCoordinator object
        self.appCoordinator = coordinator

        // call start on the coordinator
        coordinator.start()
    }

    
    // setup firebase early
    private func configureEarlyInfrastructure() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        Database.database().isPersistenceEnabled = true
    }
}
