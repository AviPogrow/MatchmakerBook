//
//  MainTabCoordinator.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/25/26.
//  Copyright © 2026 user. All rights reserved.
//

import SwiftUI
import UIKit

@MainActor
final class MainTabCoordinator {

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    func start() -> UITabBarController {
        let tabBarController = UITabBarController()

        let girlsVC = makeGirlsFlow()
        let boysVC = makeBoysFlow()
        let dashboardVC = makeDashboardFlow()

        tabBarController.viewControllers = [
            girlsVC,
            boysVC,
            dashboardVC
        ]

        return tabBarController
    }

    private func makeGirlsFlow() -> UIViewController {
        let nav = UINavigationController()
        nav.tabBarItem = UITabBarItem(
            title: "Girls",
            image: UIImage(systemName: "person.2"),
            tag: 0
        )

        // Later:
        // let coordinator = GirlsCoordinator(nav: nav, container: container)
        // coordinator.start()

        return nav
    }

    private func makeBoysFlow() -> UIViewController {
        let nav = UINavigationController()
        nav.tabBarItem = UITabBarItem(
            title: "Boys",
            image: UIImage(systemName: "person"),
            tag: 1
        )

        return nav
    }

    private func makeDashboardFlow() -> UIViewController {
        let nav = UINavigationController()
        nav.tabBarItem = UITabBarItem(
            title: "Dashboard",
            image: UIImage(systemName: "house"),
            tag: 2
        )

        return nav
    }
}
