//
//  Coordinators.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 3/9/26.
//  Copyright © 2026 user. All rights reserved.
//

import UIKit

final class AppLifecycleCoordinator {
    static let shared = AppLifecycleCoordinator()

    private init() {}

    func applicationWillResignActive() {
        // App is about to move from active to inactive.
        // Good place to pause temporary UI-driven work if needed.
    }

    func applicationDidEnterBackground() {
        // App entered background.
        // We will later save draft state, navigation state,
        // and cancel non-essential work here.
    }

    func applicationWillEnterForeground() {
        // App is moving from background to foreground.
    }

    func applicationDidBecomeActive() {
        // App became active again.
        // We will later refresh data / retry pending work here.
    }
}
