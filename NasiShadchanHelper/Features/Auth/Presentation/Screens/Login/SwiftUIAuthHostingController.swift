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

    // we pass the LoginViewModel to then
    // inject it into the LoginView init
    // and set LoginView as the rootView
    init(viewModel: LoginViewModel) {
           super.init(rootView: LoginView(viewModel: viewModel))
       }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
}
