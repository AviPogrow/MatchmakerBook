//
//  AppLaunchCoordinator.swift.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/7/26.
//  Copyright © 2026 user. All rights reserved.
//



import Foundation

enum AppLaunchFlow {
    case showLogin
    case showMainApp
}

final class AppLaunchCoordinator {
    
    enum PendingRoute {
        case importResume
    }
    
    private(set) var pendingRoute: PendingRoute?

    func start(isLoggedIn: Bool) -> AppLaunchFlow {

        if isLoggedIn {
            return .showMainApp
        } else {
            return .showLogin
        }
    }
    
    func handle(url: URL) {

        guard url.scheme == "matchmaker" else { return }

        if url.host == "import-resume" {
            pendingRoute = .importResume
        }
    }
    
    
}
