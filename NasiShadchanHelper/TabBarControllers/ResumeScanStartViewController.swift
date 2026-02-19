//
//  ResumeScanStartViewController.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 2/16/26.
//  Copyright © 2026 user. All rights reserved.
//

import UIKit


final class ResumeScanStartViewController: UIViewController {

        private let previewImageView = UIImageView()
        private let takePhotoButton = UIButton(type: .system)
        private let choosePhotoButton = UIButton(type: .system)
        private let tipsLabel = UILabel()

        private var selectedImage: UIImage? {
            didSet {
                previewImageView.image = selectedImage
                navigationItem.rightBarButtonItem?.isEnabled = (selectedImage != nil)
                previewImageView.contentMode = selectedImage == nil ? .center : .scaleAspectFit
                previewImageView.tintColor = .tertiaryLabel
            }
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            title = "Scan Resume"

            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Next",
                style: .done,
                target: self,
                action: #selector(didTapNext)
            )
            navigationItem.rightBarButtonItem?.isEnabled = false

            buildUI()
            selectedImage = nil
        }

        private func buildUI() {
            let previewCard = cardView()

            previewImageView.translatesAutoresizingMaskIntoConstraints = false
            previewImageView.image = UIImage(systemName: "doc.text.viewfinder")
            previewImageView.contentMode = .center
            previewImageView.tintColor = .tertiaryLabel

            previewCard.addSubview(previewImageView)
            NSLayoutConstraint.activate([
                previewImageView.topAnchor.constraint(equalTo: previewCard.topAnchor, constant: 16),
                previewImageView.bottomAnchor.constraint(equalTo: previewCard.bottomAnchor, constant: -16),
                previewImageView.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor, constant: 16),
                previewImageView.trailingAnchor.constraint(equalTo: previewCard.trailingAnchor, constant: -16),

                previewCard.heightAnchor.constraint(equalToConstant: 260) // or 280
            ])

            var takeConfig = UIButton.Configuration.filled()
            takeConfig.title = "Take Photo"
            takeConfig.image = UIImage(systemName: "camera")
            takeConfig.imagePadding = 8
            takeConfig.cornerStyle = .large
            takePhotoButton.configuration = takeConfig
            takePhotoButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)

            var chooseConfig = UIButton.Configuration.tinted()
            chooseConfig.title = "Choose From Photos"
            chooseConfig.image = UIImage(systemName: "photo.on.rectangle")
            chooseConfig.imagePadding = 8
            chooseConfig.cornerStyle = .large
            choosePhotoButton.configuration = chooseConfig
            choosePhotoButton.addTarget(self, action: #selector(didTapChoosePhoto), for: .touchUpInside)

            tipsLabel.text = "Best results: bright light, flat page, fill the frame."
            tipsLabel.font = .systemFont(ofSize: 13)
            tipsLabel.textColor = .secondaryLabel
            tipsLabel.numberOfLines = 0

            let buttonsStack = UIStackView(arrangedSubviews: [takePhotoButton, choosePhotoButton])
            buttonsStack.axis = .vertical
            buttonsStack.spacing = 10

            let root = UIStackView(arrangedSubviews: [previewCard, buttonsStack, tipsLabel, UIView()])
            root.axis = .vertical
            root.spacing = 14

            view.addSubview(root)
            root.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                root.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            ])
        }

        private func cardView() -> UIView {
            let v = UIView()
            v.backgroundColor = .secondarySystemBackground
            v.layer.cornerRadius = 14
            v.layer.masksToBounds = true
            return v
        }

        @objc private func didTapNext() {
            guard let image = selectedImage else { return }

            // 1) Run OCR (async)
            // 2) Push OCRReviewViewController and pass recognized text
            let reviewVC = OCRReviewViewController()
            reviewVC.setOCRText("…recognized text goes here…") // replace with your OCR output
            navigationController?.pushViewController(reviewVC, animated: true)
        }

        @objc private func didTapTakePhoto() {
            presentImagePicker(sourceType: .camera)
        }

        @objc private func didTapChoosePhoto() {
            presentImagePicker(sourceType: .photoLibrary)
        }
    }
extension ResumeScanStartViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }

        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        selectedImage = image
    }
}
