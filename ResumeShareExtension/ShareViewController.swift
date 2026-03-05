//
//  ShareViewController.swift
//  ResumeShareExtension
//
//  Created by Avi Pogrow on 2/27/26.
//  Copyright © 2026 user. All rights reserved.
//
import UIKit
import Social
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {

    // MARK: - App Group / Payload

    private let appGroupID = "group.com.AviPogrow.NasiShadchanHelper"
    private let payloadKey = "latestSharedResumePayload"

    private var capturedPayload: [String: Any]?

    // MARK: - UI

    private let headerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Share to Connect"
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    private let docsTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "📎 Documents"
        l.font = .systemFont(ofSize: 22, weight: .bold)
        return l
    }()

    private let fileCardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.secondarySystemBackground
        v.layer.cornerRadius = 18
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 12
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        return v
    }()

    private let fileIconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .secondaryLabel
        iv.image = UIImage(systemName: "doc")
        iv.backgroundColor = UIColor.tertiarySystemBackground
        iv.layer.cornerRadius = 14
        iv.clipsToBounds = true
        return iv
    }()

    private let fileNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "No file shared"
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.numberOfLines = 2
        return l
    }()

    private let fileTypeLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Share a PDF, image, or text resume"
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        return l
    }()

    private let bioTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "✏️ Bio"
        l.font = .systemFont(ofSize: 22, weight: .bold)
        return l
    }()

    private let bioTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.secondarySystemBackground
        tv.layer.cornerRadius = 18
        tv.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        tv.font = .systemFont(ofSize: 17)
        tv.textColor = .label
        tv.returnKeyType = .done
        tv.autocorrectionType = .yes
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.isSelectable = false
        tv.isUserInteractionEnabled = false
        
        return tv
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Preparing import…"
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()

    private let cancelButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Cancel"
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .secondarySystemBackground
        config.baseForegroundColor = .label

        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let importButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Import to Nasi"
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white

        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isEnabled = false
        b.alpha = 0.5
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide the standard compose UI
      

        view.backgroundColor = .systemBackground

        layoutUI()

        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        importButton.addTarget(self, action: #selector(didTapImport), for: .touchUpInside)

        // Capture immediately, but do NOT open host app automatically
        importFirstSupportedAttachment()
    }

    

    // MARK: - Layout

    private func layoutUI() {
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(content)

        content.addSubview(headerLabel)
        content.addSubview(docsTitleLabel)
        content.addSubview(fileCardView)
        content.addSubview(bioTitleLabel)
        content.addSubview(bioTextView)
        content.addSubview(statusLabel)
        content.addSubview(cancelButton)
        content.addSubview(importButton)

        fileCardView.addSubview(fileIconView)
        fileCardView.addSubview(fileNameLabel)
        fileCardView.addSubview(fileTypeLabel)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            content.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),

            headerLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 10),
            headerLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor),

            docsTitleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 18),
            docsTitleLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            docsTitleLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor),

            fileCardView.topAnchor.constraint(equalTo: docsTitleLabel.bottomAnchor, constant: 12),
            fileCardView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            fileCardView.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            fileCardView.heightAnchor.constraint(equalToConstant: 92),

            fileIconView.leadingAnchor.constraint(equalTo: fileCardView.leadingAnchor, constant: 14),
            fileIconView.centerYAnchor.constraint(equalTo: fileCardView.centerYAnchor),
            fileIconView.widthAnchor.constraint(equalToConstant: 56),
            fileIconView.heightAnchor.constraint(equalToConstant: 56),

            fileNameLabel.topAnchor.constraint(equalTo: fileCardView.topAnchor, constant: 18),
            fileNameLabel.leadingAnchor.constraint(equalTo: fileIconView.trailingAnchor, constant: 12),
            fileNameLabel.trailingAnchor.constraint(equalTo: fileCardView.trailingAnchor, constant: -14),

            fileTypeLabel.topAnchor.constraint(equalTo: fileNameLabel.bottomAnchor, constant: 4),
            fileTypeLabel.leadingAnchor.constraint(equalTo: fileNameLabel.leadingAnchor),
            fileTypeLabel.trailingAnchor.constraint(equalTo: fileNameLabel.trailingAnchor),

            bioTitleLabel.topAnchor.constraint(equalTo: fileCardView.bottomAnchor, constant: 22),
            bioTitleLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            bioTitleLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor),

            bioTextView.topAnchor.constraint(equalTo: bioTitleLabel.bottomAnchor, constant: 10),
            bioTextView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            bioTextView.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            bioTextView.heightAnchor.constraint(equalToConstant: 180),

            statusLabel.topAnchor.constraint(equalTo: bioTextView.bottomAnchor, constant: 14),
            statusLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 6),
            statusLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -6),

            cancelButton.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 54),

            importButton.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            importButton.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            importButton.heightAnchor.constraint(equalToConstant: 54),

            cancelButton.trailingAnchor.constraint(equalTo: content.centerXAnchor, constant: -8),
            importButton.leadingAnchor.constraint(equalTo: content.centerXAnchor, constant: 8)
        ])
    }

    private func setImportEnabled(_ enabled: Bool) {
        importButton.isEnabled = enabled
        importButton.alpha = enabled ? 1.0 : 0.5
    }

    private func setFileCard(fileName: String, typeLabel: String, icon: String) {
        fileNameLabel.text = fileName
        fileTypeLabel.text = typeLabel
        fileIconView.image = UIImage(systemName: icon)
        fileIconView.tintColor = .secondaryLabel
    }

    // MARK: - Import pipeline (capture only)

    private func importFirstSupportedAttachment() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            statusLabel.text = "No items received."
            return
        }

        for item in items {
            let providers = item.attachments ?? []
            if let provider = providers.first(where: canHandle(_:)) {
                loadAndPrepare(provider: provider)
                return
            }
        }

        statusLabel.text = "Unsupported share type."
    }

    private func canHandle(_ provider: NSItemProvider) -> Bool {
        provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) ||
        provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) ||
        provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) ||
        provider.hasItemConformingToTypeIdentifier(UTType.text.identifier)
    }

    private func loadAndPrepare(provider: NSItemProvider) {
        // Priority: PDF → Image → Text
        if provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
            loadFile(provider: provider, type: .pdf)
        } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            loadImage(provider: provider)
        } else {
            loadText(provider: provider)
        }
    }

    private func loadText(provider: NSItemProvider) {
        provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] item, _ in
            guard let self else { return }

            let text: String?
            if let s = item as? String {
                text = s
            } else if let url = item as? URL {
                text = try? String(contentsOf: url)
            } else {
                text = nil
            }

            guard let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                DispatchQueue.main.async { self.statusLabel.text = "Could not read text." }
                return
            }

            let payload: [String: Any] = ["kind": "text", "text": text]

            DispatchQueue.main.async {
                self.setFileCard(fileName: "Text", typeLabel: "Plain text", icon: "text.alignleft")
            }

            self.setReady(payload: payload, message: "Text captured. Tap Import to open Nasi.")
        }
    }

    private func loadImage(provider: NSItemProvider) {
        provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { [weak self] item, _ in
            guard let self else { return }

            if let url = item as? URL {
                self.copyToAppGroup(sourceURL: url, declaredType: .image)
                return
            }

            if let image = item as? UIImage {
                self.saveUIImageToAppGroup(image)
                return
            }

            DispatchQueue.main.async { self.statusLabel.text = "Could not read image." }
        }
    }

    private func loadFile(provider: NSItemProvider, type: UTType) {
        provider.loadItem(forTypeIdentifier: type.identifier, options: nil) { [weak self] item, _ in
            guard let self else { return }

            guard let url = item as? URL else {
                DispatchQueue.main.async { self.statusLabel.text = "Could not read file." }
                return
            }

            self.copyToAppGroup(sourceURL: url, declaredType: type)
        }
    }

    // MARK: - Reliable App Group file writing

    private func copyToAppGroup(sourceURL: URL, declaredType: UTType) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            DispatchQueue.main.async { self.statusLabel.text = "App Group container not available." }
            return
        }

        let ext = sourceURL.pathExtension.isEmpty
            ? (declaredType.preferredFilenameExtension ?? "dat")
            : sourceURL.pathExtension

        let filename = sourceURL.lastPathComponent.isEmpty
            ? "shared_resume_\(UUID().uuidString).\(ext)"
            : sourceURL.lastPathComponent

        let destURL = containerURL.appendingPathComponent(filename)

        do {
            let didStart = sourceURL.startAccessingSecurityScopedResource()
            defer { if didStart { sourceURL.stopAccessingSecurityScopedResource() } }

            // Read bytes and write into App Group
            let data = try Data(contentsOf: sourceURL)

            if FileManager.default.fileExists(atPath: destURL.path) {
                try FileManager.default.removeItem(at: destURL)
            }
            try data.write(to: destURL, options: [.atomic])

            let payload: [String: Any] = ["kind": "file", "path": destURL.path, "uti": declaredType.identifier]

            DispatchQueue.main.async {
                let icon = (declaredType == .pdf) ? "doc.richtext" : "photo"
                let typeLabel = (declaredType == .pdf) ? "PDF Resume" : "Image"
                self.setFileCard(fileName: filename, typeLabel: typeLabel, icon: icon)
            }

            setReady(payload: payload, message: "File captured. Tap Import to open Nasi.")

        } catch {
            DispatchQueue.main.async {
                self.statusLabel.text = "Failed to copy into App Group."
            }
            print("❌ copyToAppGroup error:", error)
        }
    }

    private func saveUIImageToAppGroup(_ image: UIImage) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            DispatchQueue.main.async { self.statusLabel.text = "App Group container not available." }
            return
        }

        let filename = "shared_resume_\(UUID().uuidString).png"
        let destURL = containerURL.appendingPathComponent(filename)

        guard let data = image.pngData() else {
            DispatchQueue.main.async { self.statusLabel.text = "Failed to encode image." }
            return
        }

        do {
            try data.write(to: destURL, options: [.atomic])

            let payload: [String: Any] = ["kind": "file", "path": destURL.path, "uti": UTType.png.identifier]

            DispatchQueue.main.async {
                self.setFileCard(fileName: filename, typeLabel: "Image", icon: "photo")
            }

            setReady(payload: payload, message: "Image captured. Tap Import to open Nasi.")

        } catch {
            DispatchQueue.main.async { self.statusLabel.text = "Failed to save image into App Group." }
        }
    }

    // MARK: - Capture state

    private func setReady(payload: [String: Any], message: String) {
        DispatchQueue.main.async {
            self.capturedPayload = payload
            self.statusLabel.text = message
            self.setImportEnabled(true)
        }
    }

    private func persistCapturedPayloadToAppGroup() {
        guard let payload = capturedPayload else { return }

        // Optional: add bio into payload if provided
        let bio = bioTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !bio.isEmpty {
            var p = payload
            p["bio"] = bio
            capturedPayload = p
        }

        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(capturedPayload, forKey: payloadKey)
        defaults?.synchronize()
        print("✅ EXT persisted payload:", capturedPayload ?? [:])
    }

    // MARK: - Buttons

    @objc private func didTapCancel() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    @objc private func didTapImport() {
        persistCapturedPayloadToAppGroup()

        guard let url = URL(string: "matchmaker://import-resume") else {
            statusLabel.text = "Bad deep link URL."
            return
        }

        extensionContext?.open(url) { [weak self] success in
            print("✅ EXT openHostApp success:", success)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            }
        }
    }
}
