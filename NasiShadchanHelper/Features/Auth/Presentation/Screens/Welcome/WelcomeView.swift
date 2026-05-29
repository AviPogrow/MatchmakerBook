//
//  WelcomeView.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/28/26.
//  Copyright © 2026 user. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {

    @ObservedObject var viewModel: WelcomeViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome")
                .font(.largeTitle)
                .bold()

            Text("Nasi Shadchan Helper")
                .font(.title3)
                .foregroundStyle(.secondary)

            Button("Login") {
                viewModel.loginTapped()
            }
            .buttonStyle(.borderedProminent)

            Button("Sign Up") {
                viewModel.signupTapped()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
