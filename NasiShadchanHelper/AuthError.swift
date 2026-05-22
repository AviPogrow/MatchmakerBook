//
//  AuthError.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/14/26.
//  Copyright © 2026 user. All rights reserved.
//
import Foundation

enum AuthError: LocalizedError, Equatable {
    case invalidCredentials
    case networkError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Unable to connect. Please try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
