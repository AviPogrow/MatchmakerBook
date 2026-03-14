//
//  SearchResultCell
//  NasiShadchanHelper
//
//  Created by test on 11/25/22.
//  Copyright © 2022 user. All rights reserved.
//


import UIKit
import Kingfisher

final class SearchResultCell: UICollectionViewCell {

    // MARK: - State
    private var representedURL: String?

    var girl: NasiGirl! {
        didSet {
            configure(with: girl)
        }
    }

    // MARK: - Views
    let appIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .clear
        iv.widthAnchor.constraint(equalToConstant: 100).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 100).isActive = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderWidth = 0.5
        iv.layer.borderColor = UIColor.gray.cgColor
        iv.layer.cornerRadius = 50
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        return iv
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()

    let cityLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    let seminaryLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    let planLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        return label
    }()

    let getButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Details", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = UIColor(white: 0.95, alpha: 1)
        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
        button.layer.cornerRadius = 16
        button.isUserInteractionEnabled = false
        return button
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 8
        clipsToBounds = true
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 0.1

        let infoTopStackView = VerticalStackView(arrangedSubviews: [
            appIconImageView,
            nameLabel,
            cityLabel,
            seminaryLabel,
            getButton
        ])

        infoTopStackView.spacing = 6
        infoTopStackView.alignment = .center
        infoTopStackView.distribution = .fill

        addSubview(infoTopStackView)
        infoTopStackView.fillSuperview(padding: .init(top: 8, left: 0, bottom: 8, right: 0))

        // Optional: careful w/ rasterize if you animate/scroll heavily
        // layer.shouldRasterize = true
        // layer.rasterizationScale = UIScreen.main.scale

        appIconImageView.image = makeGrayPlaceholder()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        representedURL = nil
        appIconImageView.kf.cancelDownloadTask()
        appIconImageView.image = makeGrayPlaceholder()
    }

    // MARK: - Configure
    private func configure(with girl: NasiGirl?) {
        guard let girl else { return }

        let heightString = "\(girl.heightInFeet)'\(girl.heightInInches)\""
        nameLabel.text = "\(girl.lastNameOfGirl) \(girl.firstNameOfGirl) - \(heightString)"
        cityLabel.text = "\(girl.age) yrs - \(girl.cityOfResidence)"
        seminaryLabel.text = girl.seminaryName
        planLabel.text = girl.plan
        planLabel.textColor = .lightGray

        let urlString = (girl.imageDownloadURLString ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !urlString.isEmpty else {
            representedURL = nil
            appIconImageView.image = makeGrayPlaceholder()
            return
        }

        if representedURL == urlString { return }
        representedURL = urlString

        guard let url = URL(string: urlString) else {
            representedURL = nil
            appIconImageView.image = makeGrayPlaceholder()
            return
        }

        appIconImageView.kf.setImage(
            with: url,
            placeholder: makeGrayPlaceholder(),
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
    }

    // MARK: - Placeholder
    private func makeGrayPlaceholder() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemGray4.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }
}
