//
//  GirlDraft.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 3/9/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation

struct GirlDraft: Codable {
    var girlFirstName: String
    var girlLastName: String
    var girlCell: String
    var city: String
    var dobIntervalString: String
    var girlHeight: String
    var lifePlans: [String]
    var sendResumeEmail: String
    var sendResumeText: String
    var shadchanNotesNew: String
    var isEditingGirl: Bool
    var girlKey: String?
}
