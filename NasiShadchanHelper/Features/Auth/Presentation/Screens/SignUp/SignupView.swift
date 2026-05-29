//
//  SignupView.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/28/26.
//  Copyright © 2026 user. All rights reserved.
//

import SwiftUI

struct SignupView: View {

    @ObservedObject var viewModel: SignupViewModel

    var body: some View {
        VStack(spacing: 20) {

            Text("Sign Up")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)

            Button("Create Account") {
                Task {
                    await viewModel.signup()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSignup)

        }
        .padding()
    }
}
