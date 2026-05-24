//
//  AppCoordinator.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/22/26.
//  Copyright © 2026 user. All rights reserved.
//

import UIKit

final class AppCoordinator {

    private let window: UIWindow
    private let container: AppContainer

    init(window: UIWindow,
         container: AppContainer) {

        self.window = window
        self.container = container
    }

    func start() {

        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground

        let nav = UINavigationController(rootViewController: vc)

        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
}
