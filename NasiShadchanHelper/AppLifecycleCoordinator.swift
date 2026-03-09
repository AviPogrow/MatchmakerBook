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
       
        DraftManager.shared.saveCurrentDraftIfNeeded()
    }
    

    func applicationWillEnterForeground() {
        // App is moving from background to foreground.
      
    }

    func applicationDidBecomeActive() {
       

        if let draft = DraftManager.shared.loadDraft() {
            print("Lifecycle: loaded draft on active for \(draft.girlFirstName) \(draft.girlLastName)")
        }
    }
}
