//
//  NavigationStateManager.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 3/11/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation


protocol NavigationStateProvider: AnyObject {
    func makeNavigationState() -> NavigationState
}

final class NavigationStateManager {

    static let shared = NavigationStateManager()

    weak var activeProvider: NavigationStateProvider?

    private init() {}

    private let navigationStateKey = "navigationState"

    func save(_ state: NavigationState) {
        do {
            let data = try JSONEncoder().encode(state)
            UserDefaults.standard.set(data, forKey: navigationStateKey)
        } catch {
            print("NavigationStateManager: failed to encode navigation state - \(error)")
        }
    }

    func load() -> NavigationState? {
        guard let data = UserDefaults.standard.data(forKey: navigationStateKey) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(NavigationState.self, from: data)
        } catch {
            print("NavigationStateManager: failed to decode navigation state - \(error)")
            return nil
        }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: navigationStateKey)
    }

    func saveCurrentStateIfNeeded() {
        guard let provider = activeProvider else { return }
        save(provider.makeNavigationState())
    }
}
