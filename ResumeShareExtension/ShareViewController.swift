//
//  ShareViewController.swift
//  ResumeShareExtension
//
//  Created by Avi Pogrow on 2/27/26.
//  Copyright © 2026 user. All rights reserved.
//
import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {

    private let appGroupID = "group.com.AviPogrow.NasiShadchanHelper"
    private let payloadKey = "latestSharedResumePayload"

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Share to Nasi"
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Import a resume into your Girls list"
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()

    private let resumeSectionTitle: UILabel = {
        let l = UILabel()
        l.text = "Documents"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.numberOfLines = 1
        return l
    }()

    private let fileCard = UIView()
    private let fileIconView = UIImageView()
    private let fileNameLabel = UILabel()
    private let fileTypeLabel = UILabel()

    private let notesSectionTitle: UILabel = {
        let l = UILabel()
        l.text = "Bio / Notes"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.numberOfLines = 1
        return l
    }()

    private let notesTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.backgroundColor = .secondarySystemBackground
        tv.layer.cornerRadius = 14
        tv.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        tv.isScrollEnabled = false
        tv.text = ""
        return tv
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.text = "Preparing import…"
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()

    private let bottomBar = UIView()
    private let cancelButton = UIButton(type: .system)
    private let importButton = UIButton(type: .system)

    // MARK: - State

    private var capturedPayload: [String: Any]?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        buildUI()
        wireActions()

        // Start capture immediately
        importFirstSupportedAttachment()
    }

    // MARK: - UI Build

    private func buildUI() {
        // Scroll + stack
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        // Bottom bar
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = .systemBackground
        view.addSubview(bottomBar)

        // Top spacing
        contentStack.addArrangedSubview(makeSpacer(10))
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(makeSpacer(6))

        // Resume section
        contentStack.addArrangedSubview(resumeSectionTitle)
        contentStack.addArrangedSubview(buildFileCard())

        // Notes section
        contentStack.addArrangedSubview(notesSectionTitle)
        contentStack.addArrangedSubview(notesTextView)

        // Status
        contentStack.addArrangedSubview(makeSpacer(8))
        contentStack.addArrangedSubview(statusLabel)
        contentStack.addArrangedSubview(makeSpacer(24))

        // Bottom buttons
        buildBottomButtons()

        NSLayoutConstraint.activate([
            // bottom bar pinned
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 84),

            // scroll view above bottom bar
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            // stack pinned inside scroll view
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 18),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -18),
        ])

        // Notes height (nice big input like screenshot)
        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        notesTextView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        // Default “no file yet”
        setFileCardEmpty()
        setImportEnabled(false)
    }

    private func buildFileCard() -> UIView {
        fileCard.translatesAutoresizingMaskIntoConstraints = false
        fileCard.backgroundColor = .secondarySystemBackground
        fileCard.layer.cornerRadius = 16

        let h = UIStackView()
        h.translatesAutoresizingMaskIntoConstraints = false
        h.axis = .horizontal
        h.spacing = 14
        h.alignment = .center

        fileIconView.translatesAutoresizingMaskIntoConstraints = false
        fileIconView.contentMode = .scaleAspectFit
        fileIconView.tintColor = .systemPink

        NSLayoutConstraint.activate([
            fileIconView.widthAnchor.constraint(equalToConstant: 44),
            fileIconView.heightAnchor.constraint(equalToConstant: 44),
        ])

        fileNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        fileNameLabel.numberOfLines = 2

        fileTypeLabel.font = .systemFont(ofSize: 14, weight: .regular)
        fileTypeLabel.textColor = .secondaryLabel
        fileTypeLabel.numberOfLines = 1

        let v = UIStackView(arrangedSubviews: [fileNameLabel, fileTypeLabel])
        v.axis = .vertical
        v.spacing = 4

        h.addArrangedSubview(fileIconView)
        h.addArrangedSubview(v)

        fileCard.addSubview(h)

        NSLayoutConstraint.activate([
            h.topAnchor.constraint(equalTo: fileCard.topAnchor, constant: 14),
            h.leadingAnchor.constraint(equalTo: fileCard.leadingAnchor, constant: 14),
            h.trailingAnchor.constraint(equalTo: fileCard.trailingAnchor, constant: -14),
            h.bottomAnchor.constraint(equalTo: fileCard.bottomAnchor, constant: -14),
        ])

        return fileCard
    }

    private func buildBottomButtons() {
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        cancelButton.layer.cornerRadius = 22
        cancelButton.layer.borderWidth = 2
        cancelButton.layer.borderColor = UIColor.label.cgColor
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)

        importButton.setTitle("Import to Nasi", for: .normal)
        importButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        importButton.layer.cornerRadius = 22
        importButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
        importButton.backgroundColor = .systemBlue
        importButton.setTitleColor(.white, for: .normal)

        let buttons = UIStackView(arrangedSubviews: [cancelButton, importButton])
        buttons.translatesAutoresizingMaskIntoConstraints = false
        buttons.axis = .horizontal
        buttons.spacing = 14
        buttons.distribution = .fillEqually

        bottomBar.addSubview(buttons)

        NSLayoutConstraint.activate([
            buttons.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 20),
            buttons.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -20),
            buttons.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            buttons.heightAnchor.constraint(equalToConstant: 52),
        ])
    }

    private func wireActions() {
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        importButton.addTarget(self, action: #selector(didTapImport), for: .touchUpInside)
    }

    private func makeSpacer(_ h: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: h).isActive = true
        return v
    }

    // MARK: - UI State

    private func setFileCardEmpty() {
        fileIconView.image = UIImage(systemName: "doc.fill")
        fileNameLabel.text = "No file selected"
        fileTypeLabel.text = "Share a PDF, image, or text"
    }

    private func setFileCard(fileName: String, typeLabel: String, icon: String) {
        fileIconView.image = UIImage(systemName: icon)
        fileNameLabel.text = fileName
        fileTypeLabel.text = typeLabel
    }

    private func setImportEnabled(_ enabled: Bool) {
        importButton.isEnabled = enabled
        importButton.alpha = enabled ? 1.0 : 0.4
    }

    @objc private func didTapCancel() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    @objc private func didTapImport() {
        // Step 2B will wire this to save payload + open app
        // For now: do nothing / keep disabled until payload is ready.
        // We'll replace this in the next step.
    }

    // MARK: - Existing pipeline hooks (keep these; we'll wire UI to them)

    private func importFirstSupportedAttachment() {
        // KEEP your existing implementation here.
        // Step 2B will update it to call `setFileCard(...)` + `setImportEnabled(true)`
    }
}
