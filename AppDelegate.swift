//
//  AppDelegate.swift
//  NasiShadchanHelper
//
//  Created by user on 4/24/20.
//  Copyright © 2020 user. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAnalytics
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties

    var handle: AuthStateDidChangeListenerHandle?

    // Keep light mode
    var window: UIWindow? {
        didSet { window?.overrideUserInterfaceStyle = .light }
    }

    // Deep-link pending flag (so Auth/root reset doesn't wipe out routing)
    private var pendingImportResume = false

    // Access shared delegate
    class func instance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    // MARK: - Init

    override init() {
        super.init()
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        Database.database().isPersistenceEnabled = true
    }

    // MARK: - App Lifecycle

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // ✅ Deep link on cold start (if launched via URL)
        if let url = launchOptions?[.url] as? URL {
            print("✅ Cold start URL in launchOptions:", url.absoluteString)
            handleDeepLink(url)
        } else {
            print("ℹ️ No launchOptions URL")
        }

        // IQKeyboardManager
        IQKeyboardManager.shared.enable = true

        // ✅ Fix: store listener handle on the property (don’t shadow with local `let handle = ...`)
        self.handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }

            if user == nil {
                self.makingRootFlow(Constant.AppRootFlow.kAuthVc)
            } else {
                self.makingRootFlow(Constant.AppRootFlow.kEnterApp)
            }
        }

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        AppLifecycleCoordinator.shared.applicationWillResignActive()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        AppLifecycleCoordinator.shared.applicationDidEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        AppLifecycleCoordinator.shared.applicationWillEnterForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppLifecycleCoordinator.shared.applicationDidBecomeActive()

        //“Restore onto the same tab the user was on when the state was saved.”
        guard let tabBarController = window?.rootViewController as? UITabBarController,
              let state = NavigationStateManager.shared.load() else {
            return
        }

        guard state.tabIndex < (tabBarController.viewControllers?.count ?? 0),
              let nav = tabBarController.viewControllers?[state.tabIndex] as? UINavigationController else {
            return
        }

        tabBarController.selectedIndex = state.tabIndex
        AppLifecycleCoordinator.shared.restoreNavigationIfNeeded(using: nav)
    }
    
    

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        print("✅ AppDelegate openURL called:", url.absoluteString)
        handleDeepLink(url)
        return true
    }

    // MARK: - Deep Link Handling

    private func handleDeepLink(_ url: URL) {
        print("✅ handleDeepLink:", url.absoluteString)

        guard url.scheme == "matchmaker" else { return }

        if url.host == "import-resume" {
            print("✅ Deep link matched import-resume (pendingImportResume = true)")
            pendingImportResume = true
            tryProcessPendingImport()
        }
    }

    private func tryProcessPendingImport() {
        guard pendingImportResume else { return }
        guard window?.rootViewController != nil else {
            print("ℹ️ Root not set yet; will process import after makingRootFlow()")
            return
        }

        pendingImportResume = false
        print("✅ Processing pending import now → calling ResumeImportRouter")
        ResumeImportRouter.shared.handleIncomingShare()
    }

    // MARK: - Making RootView Controller

    func makingRootFlow(_ strRoot: String) {

        window?.rootViewController?.removeFromParent()

        if strRoot == Constant.AppRootFlow.kEnterApp {

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBar = storyboard.instantiateViewController(withIdentifier: "MyTabBarController")
            window?.rootViewController = tabBar

        } else if strRoot == Constant.AppRootFlow.kAuthVc {

            let authStoryboard = UIStoryboard(name: "UserAuthentication", bundle: nil)
            let vcNav: AuthNavViewController = authStoryboard.instantiateViewController()
            window?.rootViewController = vcNav
        }

        // ✅ Now that root exists (and auth flow may have just reset it), try routing
        tryProcessPendingImport()
    }

    // MARK: - Optional UI Appearance

    private func setUpNavigationAppearance() {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = .yellow
        UINavigationBar.appearance().backgroundColor = .green
        UIBarButtonItem.appearance().tintColor = UIColor.red
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.white
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor.white],
            for: .normal
        )
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}




extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
            
            translatesAutoresizingMaskIntoConstraints = false
            
            if let top = top {
                self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
            }
            
            if let left = left {
                self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
            }
            
            if let bottom = bottom {
                bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
            }
            
            if let right = right {
                rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
            }
            
            if width != 0 {
                widthAnchor.constraint(equalToConstant: width).isActive = true
            }
            
            if height != 0 {
                heightAnchor.constraint(equalToConstant: height).isActive = true
            }
        }
    
    func fillSuperview(padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewTopAnchor = superview?.topAnchor {
            topAnchor.constraint(equalTo: superviewTopAnchor, constant: padding.top).isActive = true
        }
        
        if let superviewBottomAnchor = superview?.bottomAnchor {
            bottomAnchor.constraint(equalTo: superviewBottomAnchor, constant: -padding.bottom).isActive = true
        }
        
        if let superviewLeadingAnchor = superview?.leadingAnchor {
            leadingAnchor.constraint(equalTo: superviewLeadingAnchor, constant: padding.left).isActive = true
        }
        
        if let superviewTrailingAnchor = superview?.trailingAnchor {
            trailingAnchor.constraint(equalTo: superviewTrailingAnchor, constant: -padding.right).isActive = true
        }
    }
    
    func centerInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
        
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
}


































