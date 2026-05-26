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
    
    private var nasiGirlsCoordinator: NasiGirlsCoordinator?
    
    private let container: AppContainer
    var onLogout: (() -> Void)?
    
    init(container: AppContainer) {
        self.container = container
    }
    
    
    
    func start() -> UITabBarController {
        let girlsNav = UINavigationController()

        let girlsCoordinator = NasiGirlsCoordinator(
            navigationController: girlsNav,
            container: container
        )
        girlsCoordinator.start()
        
        girlsNav.tabBarItem = UITabBarItem(
            title: "Nasi Girls",
            image: UIImage(systemName: "person.3"),
            tag: 0
        )
        self.nasiGirlsCoordinator = girlsCoordinator
        
        let tabBarController = UITabBarController()

        tabBarController.viewControllers = [makeGirlsFlow(),makeBoysFlow(),makeDashboardFlow(),girlsNav
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
        
        
       let dashboardVC = DashboardViewController()
        
        dashboardVC.onLogoutTapped = { [weak self] in
            guard let self else { return }
          
            do {
                try self.container.authService.logout()
               self.onLogout?()
           } catch {
               print("Logout failed: \(error)")
           }
        }
        
        let nav = UINavigationController(rootViewController: dashboardVC)
         
        nav.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(systemName: "house"), tag: 0)
        
        return nav
    }
}
