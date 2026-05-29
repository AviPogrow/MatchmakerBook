//
//  WelcomeHostingController.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/28/26.
//  Copyright © 2026 user. All rights reserved.
//

import SwiftUI

final class WelcomeHostingController: UIHostingController<WelcomeView> {

    init(viewModel: WelcomeViewModel) {
        super.init(rootView: WelcomeView(viewModel: viewModel))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
