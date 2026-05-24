import UIKit

final class AppLifecycleCoordinator {
    static let shared = AppLifecycleCoordinator()

    // Prevent navigation restoration from running multiple times during the same app session.
    // applicationDidBecomeActive can fire every time the app returns to foreground,
    // so without this guard the restore logic could push duplicate screens.
    private var didRestoreNavigation = false

    private init() {}

    func applicationWillResignActive() {
        // App is about to move from active to inactive.
        // Good place to pause temporary UI-driven work if needed.
    }

    func applicationDidEnterBackground() {
        DraftManager.shared.saveCurrentDraftIfNeeded()
        NavigationStateManager.shared.saveCurrentStateIfNeeded()
    }

    func applicationWillEnterForeground() {
        // App is moving from background to foreground.
    }

    func applicationDidBecomeActive() {
        // Keep thin for now.
    }

    func restoreNavigationIfNeeded(from tabBarController: UITabBarController) {
        guard !didRestoreNavigation else { return }
        guard let state = NavigationStateManager.shared.load() else { return }
        guard state.screenID == "addEditGirl" else { return }
        guard let viewControllers = tabBarController.viewControllers,
              state.tabIndex >= 0,
              state.tabIndex < viewControllers.count else { return }

        didRestoreNavigation = true

        tabBarController.selectedIndex = state.tabIndex

        // Defer restoration one run loop so UIKit finishes switching tabs
        // before we push onto the correct navigation controller.
        DispatchQueue.main.async {
            guard let nav = tabBarController.viewControllers?[state.tabIndex] as? UINavigationController else {
                return
            }

            self.restoreNavigationIfNeeded(using: nav, state: state)
        }
    }

    private func restoreNavigationIfNeeded(using navigationController: UINavigationController,
                                           state: NavigationState) {
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
