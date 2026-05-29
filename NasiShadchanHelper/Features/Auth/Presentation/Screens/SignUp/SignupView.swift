//
//  SignupView.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/28/26.
//  Copyright © 2026 user. All rights reserved.
//

import SwiftUI
import UIKit
import PhotosUI

struct SignupView: View {

    @ObservedObject var viewModel: SignupViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 20) {
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images
            ) {
                Text("Choose Profile Image")
            }
            .buttonStyle(.bordered)
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    guard let item = newItem else {
                        return
                    }

                    guard let data = try? await item.loadTransferable(type: Data.self) else {
                        return
                    }

                    viewModel.profileImageSelected(data)
                }
            }

            Text("Sign Up")
                .font(.largeTitle)
                .bold()
            if let data = viewModel.selectedImageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(.gray.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .overlay {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                    }
            }

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
