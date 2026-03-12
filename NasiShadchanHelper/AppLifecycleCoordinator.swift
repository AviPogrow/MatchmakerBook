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
    
    // Prevent navigation restoration from running multiple times during the same app session.
    // applicationDidBecomeActive can fire every time the app returns to foreground,
    // so without this guard the restore logic could push duplicate screens.
    private var didRestoreNavigation = false

    private init() {}

    func applicationWillResignActive() {
    }

    func applicationDidEnterBackground() {
        DraftManager.shared.saveCurrentDraftIfNeeded()
        NavigationStateManager.shared.saveCurrentStateIfNeeded()
    }

    func applicationWillEnterForeground() {
    }

    func applicationDidBecomeActive() {
    }
    func restoreNavigationIfNeeded(using navigationController: UINavigationController) {

        // Only restore once per app launch to avoid duplicate pushes
        // when the app repeatedly enters the foreground.
        guard !didRestoreNavigation else { return }
        didRestoreNavigation = true

        guard let state = NavigationStateManager.shared.load() else { return }
        guard state.screenID == "addEditGirl" else { return }

        let alreadyShowingAddEdit = navigationController.viewControllers.contains {
            $0 is AddEditGirlViewController
        }
        guard !alreadyShowingAddEdit else { return }

        let vc = AddEditGirlViewController()
        vc.isEditingGirl = state.isEditingGirl

        if state.isEditingGirl {
            vc.selectedShadchanGirl = ShadchanGirl(
                girlCell: "",
                girlLastName: "",
                girlFirstName: "",
                city: "",
                dobIntervalString: "",
                dateCreated: "",
                dateLastUpdate: 0,
                girlHeight: "",
                sendResumeEmail: "",
                sendResumeText: "",
                lifePlans: [],
                status: "available",
                datingHistory: "",
                shadchanNotesNew: "",
                notesImageURL: "",
                resumeImageURL: "",
                photoImageURL: ""
            )

            if let key = state.girlKey {
                vc.selectedShadchanGirl.key = key
            }
        } else {
            vc.initNewNasiGirl()
        }

        navigationController.pushViewController(vc, animated: false)

        if let draft = DraftManager.shared.loadDraft() {
            vc.loadViewIfNeeded()
            vc.applyDraft(draft)
        }
    }
}
