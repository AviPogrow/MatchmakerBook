//
//  FirebaseNasiGirlsRepository.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/27/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation
import Firebase

final class FirebaseNasiGirlsRepository: NasiGirlsRepository {

    func fetchNasiGirls() async throws -> [NasiGirl] {
        try await withCheckedThrowingContinuation { continuation in
            let ref = Database.database().reference().child("NasiGirlsList")

            ref.observeSingleEvent(of: .value) { snapshot in
                var girls: [NasiGirl] = []
                girls.reserveCapacity(Int(snapshot.childrenCount))

                for child in snapshot.children {
                    guard let snap = child as? DataSnapshot else { continue }
                    let nasiGirl = NasiGirl(snapshot: snap)
                    girls.append(nasiGirl)
                }

                girls = girls.filter {
                    $0.category != Constant.CategoryTypeName.CategoryEngaged1
                }

                girls.sort {
                    $0.lastNameOfGirl < $1.lastNameOfGirl
                }

                continuation.resume(returning: girls)

            } withCancel: { error in
                continuation.resume(throwing: error)
            }
        }
    }
}
