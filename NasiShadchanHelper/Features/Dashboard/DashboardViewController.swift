//
//  Untitled.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/25/26.
//  Copyright © 2026 user. All rights reserved.
//

import UIKit
final class DashboardViewController: UIViewController {

    var onLogoutTapped: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground

        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func logoutTapped() {
        onLogoutTapped?()
    }
}
