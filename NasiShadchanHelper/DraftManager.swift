//
//  DraffManager.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 3/9/26.
//  Copyright © 2026 user. All rights reserved.
//
import Foundation

protocol GirlDraftProvider: AnyObject {
    func makeDraft() -> GirlDraft
}

final class DraftManager {

    static let shared = DraftManager()

    weak var activeDraftProvider: GirlDraftProvider?

    private init() {}

    private let girlDraftKey = "girlDraft"

    func saveDraft(_ draft: GirlDraft) {
        do {
            let data = try JSONEncoder().encode(draft)
            UserDefaults.standard.set(data, forKey: girlDraftKey)
          
        } catch {
            print("DraftManager: failed to encode draft - \(error)")
        }
    }

    func loadDraft() -> GirlDraft? {
        guard let data = UserDefaults.standard.data(forKey: girlDraftKey) else {
            return nil
        }

        do {
            let draft = try JSONDecoder().decode(GirlDraft.self, from: data)
            
            return draft
        } catch {
            print("DraftManager: failed to decode draft - \(error)")
            return nil
        }
    }

    func clearDraft() {
        UserDefaults.standard.removeObject(forKey: girlDraftKey)
        
    }

    func saveCurrentDraftIfNeeded() {
        guard let provider = activeDraftProvider else {
            print("DraftManager: no active draft provider")
            return
        }

        let draft = provider.makeDraft()
     
        saveDraft(draft)
    }
}
