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

    private let appGroupID = "group.com.AviPogrow.NasiShadchanHelper"
    private let payloadKey = "latestSharedResumePayload"

    // Simple UI
    private let statusLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 16)
        l.text = "Preparing import…"
        return l
    }()

    private let openButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Open Nasi to Import", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        b.isEnabled = false
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        layoutUI()

        openButton.addTarget(self, action: #selector(didTapOpen), for: .touchUpInside)

        // Save payload right away (but do NOT try to open app automatically)
        importFirstSupportedAttachment()
    }

    private func layoutUI() {
        view.addSubview(statusLabel)
        view.addSubview(openButton)

        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),

            openButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 18),
            openButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Import pipeline (save only)

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
        provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] item, error in
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

            self.savePayload(["kind": "text", "text": text])
            self.setReady("Text captured. Tap below to open Nasi and import.")
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
            defer { if didStart { sourceURL.stopAccessingSecurityScopedResource() } }

            if FileManager.default.fileExists(atPath: destURL.path) {
                try FileManager.default.removeItem(at: destURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destURL)

            savePayload(["kind": "file", "path": destURL.path, "uti": declaredType.identifier])
            setReady("File captured. Tap below to open Nasi and import.")
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
            savePayload(["kind": "file", "path": destURL.path, "uti": UTType.png.identifier])
            setReady("Image captured. Tap below to open Nasi and import.")
        } catch {
            setError("Failed to save image into App Group.")
        }
    }

    private func savePayload(_ dict: [String: Any]) {
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(dict, forKey: payloadKey)
        defaults?.synchronize()
        print("✅ EXT saved payload:", dict)
    }

    // MARK: - Open app (user-initiated)

    @objc private func didTapOpen() {
        openHostApp()
    }

    private func openHostApp() {
        guard let url = URL(string: "matchmaker://import-resume") else {
            setError("Bad deep link URL.")
            return
        }

        // Prefer official method
        extensionContext?.open(url) { [weak self] success in
            print("✅ EXT openHostApp success:", success)

            if success {
                self?.finish()
            } else {
                // Fallback responder chain
                let didOpen = self?.openViaResponderChain(url) ?? false
                print("✅ EXT responderChain open attempted:", didOpen)

                // Give iOS a moment
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

    // MARK: - UI state helpers

    private func setReady(_ message: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = message
            self.openButton.isEnabled = true
        }
    }

    private func setError(_ message: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Couldn’t prepare import.\n\n\(message)"
            self.openButton.setTitle("Close", for: .normal)
            self.openButton.isEnabled = true
            self.openButton.removeTarget(nil, action: nil, for: .allEvents)
            self.openButton.addTarget(self, action: #selector(self.didTapClose), for: .touchUpInside)
        }
    }

    @objc private func didTapClose() {
        finish()
    }

    
}
