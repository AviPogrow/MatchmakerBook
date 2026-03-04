//
//  ResumeImportRouter.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 2/27/26.
//  Copyright © 2026 user. All rights reserved.
//
import UIKit

final class ResumeImportRouter {

    static let shared = ResumeImportRouter()

    private let appGroupID = "group.com.AviPogrow.NasiShadchanHelper"
    private let payloadKey = "latestSharedResumePayload"

    enum IncomingPayload {
        case file(url: URL, uti: String)
        case text(String)
    }

    // MARK: - Entry point

    
    
    
    
    func handleIncomingShare() {
        
       
        
        guard let payload = readPayload() else {
            print("ResumeImportRouter: no payload found")
            return
        }
        
       
        DispatchQueue.main.async {
            guard let window = AppDelegate.instance().window,
                  let root = window.rootViewController else {
                print("ResumeImportRouter: missing window/rootViewController")
                return
            }

            let targetVC = DebugImportViewController(payload: payload)

            // Prefer pushing onto an existing nav stack
            if let nav = self.bestNav(from: root) {
                nav.popToRootViewController(animated: false)
                nav.pushViewController(targetVC, animated: true)
                return
            }

            // Fallback: present modally from the currently visible controller
            let presenter = self.topMost(from: root)
            presenter.present(targetVC, animated: true)
        }
    }

    // MARK: - Navigation helpers

    /// Finds the "best" UINavigationController to push onto, searching common container patterns.
    private func bestNav(from root: UIViewController?) -> UINavigationController? {
        guard let root else { return nil }

        if let nav = root as? UINavigationController { return nav }

        if let tab = root as? UITabBarController {
            // If the selected VC is a nav controller, use it;
            // otherwise try its navigationController.
            return (tab.selectedViewController as? UINavigationController)
                ?? tab.selectedViewController?.navigationController
        }

        // If root is embedded in a nav controller already:
        if let nav = root.navigationController { return nav }

        // Recurse into presented controllers
        if let presented = root.presentedViewController {
            return bestNav(from: presented)
        }

        return nil
    }

    /// Returns the top-most visible view controller to present from.
    private func topMost(from root: UIViewController) -> UIViewController {
        // Walk presented stack
        var top: UIViewController = root
        while let presented = top.presentedViewController {
            top = presented
        }

        // Dive into containers
        if let tab = top as? UITabBarController, let selected = tab.selectedViewController {
            return topMost(from: selected)
        }

        if let nav = top as? UINavigationController, let visible = nav.visibleViewController {
            return topMost(from: visible)
        }

        return top
    }

    // MARK: - Payload reading

    private func readPayload() -> IncomingPayload? {
        let defaults = UserDefaults(suiteName: appGroupID)
        guard let dict = defaults?.dictionary(forKey: payloadKey),
              let kind = dict["kind"] as? String else { return nil }

        if kind == "file",
           let path = dict["path"] as? String,
           let uti = dict["uti"] as? String {
            return .file(url: URL(fileURLWithPath: path), uti: uti)
        }

        if kind == "text",
           let text = dict["text"] as? String {
            return .text(text)
        }

        return nil
    }
}
