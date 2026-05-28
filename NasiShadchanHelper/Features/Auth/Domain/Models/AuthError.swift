//
//  AuthError.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/14/26.
//  Copyright © 2026 user. All rights reserved.
//
import Foundation

enum AuthError: Error, Equatable {
    case invalidEmail
    case emptyPassword
    case unknown
}
