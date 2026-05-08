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

enum PendingRoute {
    case importResume
}

final class AppLaunchCoordinator {

    private(set) var pendingRoute: PendingRoute?

    private let resumeImportRouter: ResumeImportRouting?
    private let sessionManager: SessionManaging?

    init(
        resumeImportRouter: ResumeImportRouting? = nil,
        sessionManager: SessionManaging? = nil
    ) {
        self.resumeImportRouter = resumeImportRouter
        self.sessionManager = sessionManager
    }

    func start() -> AppLaunchFlow {
        let loggedIn = sessionManager?.isLoggedIn() ?? false
        return start(isLoggedIn: loggedIn)
    }

    func start(isLoggedIn: Bool) -> AppLaunchFlow {
        isLoggedIn ? .showMainApp : .showLogin
    }

    func handle(url: URL) {
        guard url.scheme == "matchmaker" else { return }

        if url.host == "import-resume" {
            pendingRoute = .importResume
        }
    }

    func processPendingRoute(isMainAppReady: Bool) {
        guard isMainAppReady else { return }
        guard let pendingRoute else { return }

        switch pendingRoute {
        case .importResume:
            resumeImportRouter?.handleIncomingShare()
            self.pendingRoute = nil
        }
    }
}
