//
//  NasiGirlsRepository.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/27/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation

protocol NasiGirlsRepository {
    func fetchNasiGirls() async throws -> [NasiGirl]
}
