//
//  SignupHostingController.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/28/26.
//  Copyright © 2026 user. All rights reserved.
//

import SwiftUI

final class SignupHostingController: UIHostingController<SignupView> {

    init(viewModel: SignupViewModel) {
        super.init(rootView: SignupView(viewModel: viewModel))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
