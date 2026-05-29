//
//  MockProfileImageUploader.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/29/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation

final class MockProfileImageUploader: ProfileImageUploading {

    func uploadProfileImage(
        data: Data,
        userID: String
    ) async throws -> URL {

        try await Task.sleep(
            nanoseconds: 2_000_000_000
        )

        return URL(
            string: "https://example.com/profile.jpg"
        )!
    }
}
