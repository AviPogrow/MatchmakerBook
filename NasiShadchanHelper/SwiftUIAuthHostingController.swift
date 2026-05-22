//
//  SwiftUIAuthHostingController.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/8/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation

import SwiftUI

final class SwiftUIAuthHostingController: UIHostingController<LoginView> {

    init() {
        super.init(rootView: LoginView())
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: LoginView())
    }
}
