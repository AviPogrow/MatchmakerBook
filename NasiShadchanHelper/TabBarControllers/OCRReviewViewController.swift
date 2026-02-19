//
//  OCRReviewViewController.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 2/16/26.
//  Copyright © 2026 user. All rights reserved.
//

import UIKit
final class ParseActionButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
        config.imagePadding = 8
        config.titleAlignment = .leading

        self.configuration = config
        self.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)

        layer.cornerRadius = 12
        layer.masksToBounds = true
        heightAnchor.constraint(equalToConstant: 48).isActive = true

        updateAppearance()
    }

    override var isEnabled: Bool {
        didSet { updateAppearance() }
    }

    private func updateAppearance() {
        if isEnabled {
            configuration?.baseBackgroundColor = .systemBlue
            configuration?.baseForegroundColor = .white
            configuration?.image = UIImage(systemName: "wand.and.stars")
            alpha = 1.0
        } else {
            configuration?.baseBackgroundColor = .tertiarySystemFill
            configuration?.baseForegroundColor = .secondaryLabel
            configuration?.image = UIImage(systemName: "lock.fill")
            alpha = 1.0 // keep alpha full; rely on colors so it stays readable
        }
    }
}

final class OCRReviewViewController: UIViewController {

    private let statusLabel = UILabel()
    private let copyButton = UIButton(type: .system)
    private let textView = UITextView()

    private let parsingTitleLabel = UILabel()
    private let parsingHintLabel = UILabel()
    private let parsingStack = UIStackView()

    private var parsedButtons: [ParseActionButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground

        title = "Resume Text"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        navigationItem.rightBarButtonItem?.isEnabled = false

        buildUI()
        configureParsingButtons()
    }

    private func buildUI() {
        // Status row card
        let statusCard = cardView()
        statusLabel.text = "Scanned • Review for accuracy"
        statusLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        statusLabel.textColor = .secondaryLabel

        var copyConfig = UIButton.Configuration.tinted()
        copyConfig.title = "Copy"
        copyConfig.image = UIImage(systemName: "doc.on.doc")
        copyConfig.imagePadding = 6
        copyConfig.cornerStyle = .medium
        copyButton.configuration = copyConfig
        copyButton.setContentHuggingPriority(.required, for: .horizontal)
        copyButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        statusLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        copyButton.addTarget(self, action: #selector(didTapCopy), for: .touchUpInside)

        let statusRow = UIStackView(arrangedSubviews: [statusLabel, UIView(), copyButton])
        statusRow.axis = .horizontal
        statusRow.alignment = .center
        statusRow.spacing = 10

        statusCard.addSubview(statusRow)
        statusRow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusRow.topAnchor.constraint(equalTo: statusCard.topAnchor, constant: 12),
            statusRow.bottomAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: -12),
            statusRow.leadingAnchor.constraint(equalTo: statusCard.leadingAnchor, constant: 12),
            statusRow.trailingAnchor.constraint(equalTo: statusCard.trailingAnchor, constant: -12),
        ])

        // Text card
        let textCard = cardView()
        textView.font = .systemFont(ofSize: 15)
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.delegate = self

        textCard.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        textCard.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: textCard.topAnchor),
            textView.bottomAnchor.constraint(equalTo: textCard.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: textCard.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: textCard.trailingAnchor),
        ])

        // Parsing card
        let parsingCard = cardView()
        parsingCard.setContentCompressionResistancePriority(.required, for: .vertical)
        parsingTitleLabel.text = "Parsing (Coming Soon)"
        parsingTitleLabel.font = .systemFont(ofSize: 15, weight: .bold)

        parsingHintLabel.text = "Buttons are disabled for now. Parsing will be added in a future update."
        parsingHintLabel.font = .systemFont(ofSize: 13)
        parsingHintLabel.textColor = .secondaryLabel
        parsingHintLabel.numberOfLines = 0

        parsingStack.axis = .vertical
        parsingStack.spacing = 10

        let parsingHeader = UIStackView(arrangedSubviews: [parsingTitleLabel, UIView()])
        parsingHeader.axis = .horizontal
        parsingHeader.alignment = .center

        let parsingContent = UIStackView(arrangedSubviews: [parsingHeader, parsingHintLabel, parsingStack])
        parsingContent.axis = .vertical
        parsingContent.spacing = 8

        parsingCard.addSubview(parsingContent)
        parsingContent.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            parsingContent.topAnchor.constraint(equalTo: parsingCard.topAnchor, constant: 12),
            parsingContent.bottomAnchor.constraint(equalTo: parsingCard.bottomAnchor, constant: -12),
            parsingContent.leadingAnchor.constraint(equalTo: parsingCard.leadingAnchor, constant: 12),
            parsingContent.trailingAnchor.constraint(equalTo: parsingCard.trailingAnchor, constant: -12),
        ])

        // Main layout
        let root = UIStackView(arrangedSubviews: [statusCard, textCard, parsingCard])
        root.axis = .vertical
        root.spacing = 12

        view.addSubview(root)
        root.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            root.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),

            // Give textCard most of the height
            textCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 220),
        ])
    }

    private func cardView() -> UIView {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 14
        v.layer.masksToBounds = true
        return v
    }

    private func configureParsingButtons() {
        // 2-column grid using horizontal stacks
        let titles = [
            "Parse Name", "Parse Age / DOB",
            "Parse Height", "Parse City"
        ]

        let buttons = titles.map { title -> ParseActionButton in
            let b = ParseActionButton()
            b.setTitle(title, for: .normal)
            b.isEnabled = false // inactive for now
            b.addTarget(self, action: #selector(didTapDisabledParseButton), for: .touchUpInside)
            return b
        }
        parsedButtons = buttons

        for row in stride(from: 0, to: buttons.count, by: 2) {
            let left = buttons[row]
            let right = (row + 1 < buttons.count) ? buttons[row + 1] : UIView()

            let rowStack = UIStackView(arrangedSubviews: [left, right])
            rowStack.axis = .horizontal
            rowStack.spacing = 10
            rowStack.distribution = .fillProportionally

            parsingStack.addArrangedSubview(rowStack)
        }
    }

    func setOCRText(_ text: String) {
        textView.text = text
        navigationItem.rightBarButtonItem?.isEnabled = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @objc private func didTapCopy() {
        UIPasteboard.general.string = textView.text
        showToast("Copied")
    }

    @objc private func didTapDone() {
        // attach text to profile, save, etc.
        dismiss(animated: true)
    }

    @objc private func didTapDisabledParseButton() {
        showToast("Parsing is coming soon")
    }

    private func showToast(_ message: String) {
        // Simple lightweight toast
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.alpha = 0

        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            label.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.85),
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
        ])

        UIView.animate(withDuration: 0.2) { label.alpha = 1 }
        UIView.animate(withDuration: 0.25, delay: 1.0, options: []) {
            label.alpha = 0
        } completion: { _ in
            label.removeFromSuperview()
        }
    }
}

extension OCRReviewViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled =
            !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

