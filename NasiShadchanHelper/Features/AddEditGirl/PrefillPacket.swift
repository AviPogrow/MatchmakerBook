//
//  PrefillPacket.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 3/2/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation

enum ProfileKind {
    case girl
    case boy
}

struct PrefillPacket {
    let kind: ProfileKind
    let selectedFields: [String: String]
    let rawText: String
    let attachment: ResumeImportRouter.IncomingPayload
    let shouldAttachResume: Bool
}
