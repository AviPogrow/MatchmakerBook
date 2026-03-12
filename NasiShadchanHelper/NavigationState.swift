//
//  NavigationState.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 3/11/26.
//  Copyright © 2026 user. All rights reserved.
//
import Foundation

struct NavigationState: Codable {
    // Which screen should be restored.
    // For now we only support "addEditGirl".
    var screenID: String

    // Whether the form was in add mode or edit mode.
    var isEditingGirl: Bool

    // If editing an existing girl, store her key so we know
    // which profile context the form belonged to.
    var girlKey: String?

    // Save the selected tab index so we can restore onto
    // the correct tab's navigation stack.
    var tabIndex: Int
}
