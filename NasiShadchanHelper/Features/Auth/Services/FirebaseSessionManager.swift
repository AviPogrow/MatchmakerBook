//
//  FirebaseSessionManager.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/25/26.
//  Copyright © 2026 user. All rights reserved.
//

import FirebaseAuth

final class FirebaseSessionManager: SessionManaging {

    func isLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}
