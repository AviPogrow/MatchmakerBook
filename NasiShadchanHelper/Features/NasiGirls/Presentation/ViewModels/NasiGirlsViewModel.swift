//
//  NasiGirlsViewModel.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/27/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation

final class NasiGirlsViewModel {

    private let repository: NasiGirlsRepository

    private(set) var allGirls: [NasiGirl] = []
    private(set) var filteredGirls: [NasiGirl] = []

    init(repository: NasiGirlsRepository) {
        self.repository = repository
    }

    func loadGirls() async throws {
        let girls = try await repository.fetchNasiGirls()

        allGirls = girls
        filteredGirls = girls
    }

    func filterGirls(searchText: String) {

        guard !searchText.isEmpty else {
            filteredGirls = allGirls
            return
        }

        let lowercasedSearchText = searchText.lowercased()

        filteredGirls = allGirls.filter { girl in
            girl.lastNameOfGirl.lowercased().contains(lowercasedSearchText)
            || girl.firstNameOfGirl.lowercased().contains(lowercasedSearchText)
            || girl.cityOfResidence.lowercased().contains(lowercasedSearchText)
            || girl.seminaryName.lowercased().contains(lowercasedSearchText)
        }
    }
}
