//
//  ProfileImageUploading.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/29/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation


protocol ProfileImageUploading {
    
    func uploadProfileImage(data: Data, userID: String) async throws -> URL
}
