//
//  ParsedResumeReviewViewController.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 2/21/26.
//  Copyright © 2026 user. All rights reserved.
//
import UIKit

final class ParsedResumeReviewViewController: UITableViewController {

    struct Field {
        let key: String
        let title: String
        var value: String
        var isSelected: Bool
    }

    private var fields: [Field]
    private let rawText: String
    private let onApply: ([String: String]) -> Void
    private var showRawText = false

    init(parsed: [String: String],
         rawText: String,
         onApply: @escaping ([String: String]) -> Void) {

        func v(_ k: String) -> String { (parsed[k] ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }

        self.fields = [
            Field(key: "firstName", title: "First Name", value: v("firstName"), isSelected: !v("firstName").isEmpty),
            Field(key: "lastName",  title: "Last Name",  value: v("lastName"),  isSelected: !v("lastName").isEmpty),
            Field(key: "telephone", title: "Telephone",  value: v("telephone"), isSelected: !v("telephone").isEmpty),
            Field(key: "city",      title: "City",       value: v("city"),      isSelected: !v("city").isEmpty),
            Field(key: "height",    title: "Height",     value: v("height"),    isSelected: !v("height").isEmpty),
            Field(key: "dob",       title: "Date of Birth", value: v("dob"),    isSelected: !v("dob").isEmpty)
        ]

        self.rawText = rawText
        self.onApply = onApply

        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    var onCancel: (() -> Void)?
    var onRetake: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Review Found Details"

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Apply", style: .done, target: self, action: #selector(applyTapped)),
            UIBarButtonItem(title: "Retake", style: .plain, target: self, action: #selector(retakeTapped))
        ]

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    @objc private func retakeTapped() {
        onRetake?()
        dismiss(animated: true)
    }

    @objc private func cancelTapped() {
        onCancel?()
        //dismiss(animated: true)
    }

    @objc private func applyTapped() {
        var dict: [String: String] = [:]
        for f in fields where f.isSelected && !f.value.isEmpty {
            dict[f.key] = f.value
        }
        onApply(dict)
        //dismiss(animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int { showRawText ? 2 : 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return fields.count + 1 } // +1 toggle row
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Select what to apply" : "Raw OCR Text"
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if indexPath.section == 0 {
            if indexPath.row == fields.count {
                var content = cell.defaultContentConfiguration()
                content.text = showRawText ? "Hide raw text" : "Show raw text"
                content.textProperties.color = view.tintColor
                cell.contentConfiguration = content
                cell.accessoryView = nil
                cell.selectionStyle = .default
                return cell
            }

            let f = fields[indexPath.row]
            var content = cell.defaultContentConfiguration()
            content.text = f.title
            content.secondaryText = f.value.isEmpty ? "Not found" : f.value
            content.secondaryTextProperties.color = f.value.isEmpty ? .secondaryLabel : .label
            cell.contentConfiguration = content

            let toggle = UISwitch()
            toggle.isOn = f.isSelected
            toggle.tag = indexPath.row
            toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.selectionStyle = .none
            return cell
        }

        var content = cell.defaultContentConfiguration()
        content.text = rawText
        content.textProperties.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        content.textProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.accessoryView = nil
        cell.selectionStyle = .none
        return cell
    }

    @objc private func toggleChanged(_ sender: UISwitch) {
        fields[sender.tag].isSelected = sender.isOn
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        if indexPath.section == 0 && indexPath.row == fields.count {
            showRawText.toggle()
            tableView.reloadData()
        }
    }
}
