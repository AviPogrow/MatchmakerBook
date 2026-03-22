//
//  GirlRepository.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 3/22/26.
//  Copyright © 2026 user. All rights reserved.
//

import FirebaseDatabase
import FirebaseAuth

final class GirlRepository {

    static let shared = GirlRepository()
    private init() {}

    // MARK: - Save

    func save(_ girl: ShadchanGirl, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 0)))
            return
        }

        let ref = Database.database().reference()
            .child("PrivateGirlsList")
            .child(uid)

        let key = girl.key.isEmpty ? ref.childByAutoId().key ?? UUID().uuidString : girl.key

        let values: [String: Any] = [
            "girlCell": girl.girlCell,
            "girlLastName": girl.girlLastName,
            "girlFirstName": girl.girlFirstName,
            "city": girl.city,
            "dobIntervalString": girl.dobIntervalString,
            "dateCreated": girl.dateCreated,
            "dateLastUpdate": girl.dateLastUpdate,
            "girlHeight": girl.girlHeight,
            "sendResumeEmail": girl.sendResumeEmail,
            "sendResumeText": girl.sendResumeText,
            "lifePlans": girl.lifePlans,
            "status": girl.status,
            "datingHistory": girl.datingHistory,
            "shadchanNotesNew": girl.shadchanNotesNew,
            "notesImageURL": girl.notesImageURL,
            "resumeImageURL": girl.resumeImageURL,
            "photoImageURL": girl.photoImageURL
        ]

        ref.child(key).updateChildValues(values) { error, _ in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Fetch

    func fetchAll(completion: @escaping ([ShadchanGirl]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }

        let ref = Database.database().reference()
            .child("PrivateGirlsList")
            .child(uid)

        ref.observeSingleEvent(of: .value) { snapshot in
            var girls: [ShadchanGirl] = []

            for child in snapshot.children {
                guard let snap = child as? DataSnapshot else { continue }
                let g = ShadchanGirl(snapshot: snap)
                girls.append(g)
            }

            completion(girls)
        }
    }

    // MARK: - Delete

    func delete(_ girl: ShadchanGirl, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 0)))
            return
        }

        let ref = Database.database().reference()
            .child("PrivateGirlsList")
            .child(uid)
            .child(girl.key)

        ref.removeValue { error, _ in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
