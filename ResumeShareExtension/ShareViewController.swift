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

        importFirstSupportedAttachment()
    }

    // MARK: - UI Build

    private func buildUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = .systemBackground
        view.addSubview(bottomBar)

        contentStack.addArrangedSubview(makeSpacer(10))
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(makeSpacer(6))
        contentStack.addArrangedSubview(resumeSectionTitle)
        contentStack.addArrangedSubview(buildFileCard())
        contentStack.addArrangedSubview(notesSectionTitle)
        contentStack.addArrangedSubview(notesTextView)
        contentStack.addArrangedSubview(makeSpacer(8))
        contentStack.addArrangedSubview(statusLabel)
        contentStack.addArrangedSubview(makeSpacer(24))

        buildBottomButtons()

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 84),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 18),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -18),
        ])

        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        notesTextView.heightAnchor.constraint(equalToConstant: 200).isActive = true

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
        DispatchQueue.main.async {
            self.fileIconView.image = UIImage(systemName: "doc.fill")
            self.fileNameLabel.text = "No file selected"
            self.fileTypeLabel.text = "Share a PDF, image, or text"
        }
    }

    private func setFileCard(fileName: String, typeLabel: String, icon: String) {
        DispatchQueue.main.async {
            self.fileIconView.image = UIImage(systemName: icon)
            self.fileNameLabel.text = fileName
            self.fileTypeLabel.text = typeLabel
        }
    }

    private func setImportEnabled(_ enabled: Bool) {
        DispatchQueue.main.async {
            self.importButton.isEnabled = enabled
            self.importButton.alpha = enabled ? 1.0 : 0.4
        }
    }

    private func setReady(_ message: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = message
            self.setImportEnabled(true)
        }
    }

    private func setError(_ message: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Couldn’t prepare import.\n\n\(message)"
            self.importButton.setTitle("Close", for: .normal)
            self.importButton.isEnabled = true
            self.importButton.alpha = 1.0
            self.importButton.removeTarget(nil, action: nil, for: .allEvents)
            self.importButton.addTarget(self, action: #selector(self.didTapClose), for: .touchUpInside)
        }
    }

    // MARK: - Actions

    @objc private func didTapCancel() {
        finish()
    }

    @objc private func didTapImport() {
        if let text = notesTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !text.isEmpty {
            appendNotesToCapturedPayload(text)
        }
        openHostApp()
    }

    @objc private func didTapClose() {
        finish()
    }

    // MARK: - Import pipeline

    private func importFirstSupportedAttachment() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            setError("No items received.")
            return
        }

        for item in items {
            let providers = item.attachments ?? []
            if let provider = providers.first(where: canHandle(_:)) {
                loadAndStore(provider: provider)
                return
            }
        }

        setError("Unsupported share type.")
    }

    private func canHandle(_ provider: NSItemProvider) -> Bool {
        provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) ||
        provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) ||
        provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) ||
        provider.hasItemConformingToTypeIdentifier(UTType.text.identifier)
    }

    private func loadAndStore(provider: NSItemProvider) {
        if provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
            loadFile(provider: provider, type: .pdf)
        } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            loadImage(provider: provider)
        } else {
            loadText(provider: provider)
        }
    }

    private func loadText(provider: NSItemProvider) {
        let typeID = provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier)
            ? UTType.plainText.identifier
            : UTType.text.identifier

        provider.loadItem(forTypeIdentifier: typeID, options: nil) { [weak self] item, error in
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
                self.setError("Could not read text.")
                return
            }

            let payload: [String: Any] = ["kind": "text", "text": text]
            self.capturedPayload = payload
            self.savePayload(payload)

            let preview = String(text.prefix(80)).trimmingCharacters(in: .whitespacesAndNewlines)
            let previewName = preview.isEmpty ? "Shared text" : preview

            self.setFileCard(
                fileName: previewName,
                typeLabel: "Plain text",
                icon: "doc.text.fill"
            )
            self.setReady("Text captured. Tap Import to Nasi.")
        }
    }

    private func loadImage(provider: NSItemProvider) {
        provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { [weak self] item, error in
            guard let self else { return }

            if let url = item as? URL {
                self.copyToAppGroup(sourceURL: url, declaredType: .image)
                return
            }

            if let image = item as? UIImage {
                self.saveUIImageToAppGroup(image)
                return
            }

            self.setError("Could not read image.")
        }
    }

    private func loadFile(provider: NSItemProvider, type: UTType) {
        provider.loadItem(forTypeIdentifier: type.identifier, options: nil) { [weak self] item, error in
            guard let self else { return }

            guard let url = item as? URL else {
                self.setError("Could not read file.")
                return
            }

            self.copyToAppGroup(sourceURL: url, declaredType: type)
        }
    }

    private func copyToAppGroup(sourceURL: URL, declaredType: UTType) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            setError("App Group container not available.")
            return
        }

        let ext = sourceURL.pathExtension.isEmpty
            ? (declaredType.preferredFilenameExtension ?? "dat")
            : sourceURL.pathExtension

        let filename = "shared_resume_\(UUID().uuidString).\(ext)"
        let destURL = containerURL.appendingPathComponent(filename)

        do {
            let didStart = sourceURL.startAccessingSecurityScopedResource()
            defer {
                if didStart {
                    sourceURL.stopAccessingSecurityScopedResource()
                }
            }

            if FileManager.default.fileExists(atPath: destURL.path) {
                try FileManager.default.removeItem(at: destURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destURL)

            let payload: [String: Any] = [
                "kind": "file",
                "path": destURL.path,
                "uti": declaredType.identifier
            ]
            capturedPayload = payload
            savePayload(payload)

            let displayName = sourceURL.lastPathComponent.isEmpty ? filename : sourceURL.lastPathComponent
            let typeLabel: String
            let icon: String

            if declaredType.conforms(to: .pdf) {
                typeLabel = "PDF document"
                icon = "doc.richtext.fill"
            } else if declaredType.conforms(to: .image) {
                typeLabel = "Image"
                icon = "photo.fill"
            } else {
                typeLabel = declaredType.localizedDescription ?? declaredType.identifier
                icon = "doc.fill"
            }

            setFileCard(fileName: displayName, typeLabel: typeLabel, icon: icon)
            setReady("File captured. Tap Import to Nasi.")
        } catch {
            setError("Failed to copy file into App Group.")
        }
    }

    private func saveUIImageToAppGroup(_ image: UIImage) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            setError("App Group container not available.")
            return
        }

        let filename = "shared_resume_\(UUID().uuidString).png"
        let destURL = containerURL.appendingPathComponent(filename)

        guard let data = image.pngData() else {
            setError("Failed to encode image.")
            return
        }

        do {
            try data.write(to: destURL, options: [.atomic])

            let payload: [String: Any] = [
                "kind": "file",
                "path": destURL.path,
                "uti": UTType.png.identifier
            ]
            capturedPayload = payload
            savePayload(payload)

            setFileCard(fileName: filename, typeLabel: "Image", icon: "photo.fill")
            setReady("Image captured. Tap Import to Nasi.")
        } catch {
            setError("Failed to save image into App Group.")
        }
    }

    private func appendNotesToCapturedPayload(_ notes: String) {
        var payload = capturedPayload ?? [:]
        payload["notes"] = notes
        capturedPayload = payload
        savePayload(payload)
    }

    private func savePayload(_ dict: [String: Any]) {
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(dict, forKey: payloadKey)
        defaults?.synchronize()
        print("✅ EXT saved payload:", dict)
    }

    // MARK: - Open app

    private func openHostApp() {
        guard let url = URL(string: "matchmaker://import-resume") else {
            setError("Bad deep link URL.")
            return
        }

        extensionContext?.open(url) { [weak self] success in
            print("✅ EXT openHostApp success:", success)

            if success {
                self?.finish()
            } else {
                let didOpen = self?.openViaResponderChain(url) ?? false
                print("✅ EXT responderChain open attempted:", didOpen)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self?.finish()
                }
            }
        }
    }

    private func openViaResponderChain(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while let r = responder {
            if let app = r as? UIApplication {
                app.open(url, options: [:], completionHandler: nil)
                return true
            }
            responder = r.next
        }
        return false
    }

    private func finish() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
