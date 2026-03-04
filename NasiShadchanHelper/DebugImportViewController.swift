//
//  DebugImportViewController.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 2/27/26.
//  Copyright © 2026 user. All rights reserved.
//import UIKit
import UniformTypeIdentifiers
import PDFKit

final class DebugImportViewController: UIViewController {

    private let payload: ResumeImportRouter.IncomingPayload

    private let imageView = UIImageView()
    private let pdfView = PDFView()
    private let textView = UITextView()
    private let infoLabel = UILabel()

    init(payload: ResumeImportRouter.IncomingPayload) {
        self.payload = payload
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Debug Import"

        setupViews()
        handlePayload()
    }

    // MARK: - Setup UI

    private func setupViews() {

        // Image preview
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.systemGray6
        imageView.clipsToBounds = true

        // PDF preview
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.autoScales = true
        pdfView.backgroundColor = UIColor.systemGray6
        pdfView.isHidden = true

        // Text preview
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.systemGray6
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)

        // Info label
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.numberOfLines = 0
        infoLabel.font = .systemFont(ofSize: 14)
        infoLabel.textColor = .secondaryLabel

        view.addSubview(imageView)
        view.addSubview(pdfView)
        view.addSubview(textView)
        view.addSubview(infoLabel)

        NSLayoutConstraint.activate([
            // Image frame (PDF overlays this exact same frame)
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 280),

            // PDF overlays image frame
            pdfView.topAnchor.constraint(equalTo: imageView.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),

            // Text area
            textView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 220),

            // Info label
            infoLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Handle Payload

    private func handlePayload() {

        switch payload {

        case .file(let url, let uti):
            infoLabel.text = """
            Got FILE:
            UTI: \(uti)
            Path:
            \(url.path)
            """

            if uti == UTType.image.identifier || UTType(uti) == .image {
                // Show image
                imageView.isHidden = false
                pdfView.isHidden = true
                textView.text = nil

                imageView.image = UIImage(contentsOfFile: url.path)
                if imageView.image == nil {
                    textView.text = "⚠️ Could not load image from file."
                }

            } else if uti == UTType.pdf.identifier || UTType(uti) == .pdf {
                // Show PDF
                imageView.isHidden = true
                pdfView.isHidden = false
                textView.text = nil

                pdfView.document = PDFDocument(url: url)
                if pdfView.document == nil {
                    textView.text = "⚠️ Could not load PDF document."
                }

            } else {
                // Unknown file type
                imageView.isHidden = true
                pdfView.isHidden = true
                textView.text = "Unsupported file type: \(uti)"
            }

        case .text(let text):
            infoLabel.text = "Got TEXT payload:"
            imageView.isHidden = true
            pdfView.isHidden = true
            textView.text = text
        }
    }
}
