//
//  NavigationState.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 3/11/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation

struct NavigationState: Codable {
    var screenID: String
    var isEditingGirl: Bool
    var girlKey: String?
}
