//
//  SearchResultCell
//  NasiShadchanHelper
//
//  Created by test on 11/25/22.
//  Copyright © 2022 user. All rights reserved.
//

import UIKit


class SearchResultCell: UICollectionViewCell {
    
   
    var girl: NasiGirl! {
        didSet {
            let heightString = "\(girl.heightInFeet)" + "\'" + " " + "\(girl.heightInInches)"  + "\""
            nameLabel.text = girl!.lastNameOfGirl + " " + girl!.firstNameOfGirl + " - "
            + heightString
            
            cityLabel.text =  "\(girl!.age)" + " yrs - " + girl!.cityOfResidence
            //ageLabel.text = "\(girl!.age)"
            seminaryLabel.text = "\(girl!.seminaryName)"
            planLabel.text = "\(girl!.plan)"
            planLabel.textColor = .lightGray
            
            guard let resumeImageUrl = girl?.documentDownloadURLString else { return }
            guard let profileImageUrl = girl?.imageDownloadURLString else {return }
        
            appIconImageView.loadImageFromUrl(strUrl: profileImageUrl, imgPlaceHolder: "")
        }
    }
    
  
    
    
    let appIconImageView: UIImageView = {
        let iv = UIImageView()
        //iv.image = UIImage(named: "Abady")
        iv.backgroundColor = .clear
        iv.widthAnchor.constraint(equalToConstant: 100).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 100).isActive = true
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .black
        iv.layer.borderWidth = 0.5
        iv.layer.borderColor = UIColor.gray.cgColor
        iv.layer.cornerRadius = 50
        iv.clipsToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        //label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 14)
        label.text = "Sara Green"
        //label.backgroundColor = .lightText
        return label
    }()
    
    let cityLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Teacher"
        return label
    }()
    
    let ageLabel: UILabel = {
        let label = UILabel()
        label.text = "25.7"
        return label
    }()
    
    let seminaryLabel: UILabel = {
        let label = UILabel()
        label.text = "BJJ"
        return label
    }()
    let planLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.text = "learning"
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
    
    
    lazy var screenshot1ImageView = self.createScreenshotImageView()
    lazy var screenshot2ImageView = self.createScreenshotImageView()
    lazy var screenshot3ImageView = self.createScreenshotImageView()
    
    func createScreenshotImageView() -> UIImageView {
        let imageView = UIImageView()
        //imageView.backgroundColor = .green
        imageView.contentMode = .scaleAspectFill
       // imageView.image = UIImage(named: "Res")
        imageView.layer.cornerRadius = 8
        //imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
        
        return imageView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        //layer.shadowOpacity = 0.2
       // layer.shadowRadius = 6
        //layer.shadowOffset = .init(width: 0, height: 10)
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 0.1
        // optional
        let infoTopStackView = VerticalStackView(arrangedSubviews: [appIconImageView,
                nameLabel, cityLabel, seminaryLabel,getButton
                ])
           
            

        //infoTopStackView.backgroundColor = .green
        infoTopStackView.spacing = 6
        infoTopStackView.alignment = .center
        infoTopStackView.distribution = .fill
        
        //self.backgroundColor = .green
      // infoTopStackView.backgroundColor = .red
        addSubview(infoTopStackView)
        infoTopStackView.fillSuperview(padding: .init(top: 8, left: 0, bottom: 8, right: 0))
        layer.shouldRasterize = true
    }
    
    /*
    imageView.backgroundColor = .purple
    imageView.constrainWidth(constant: 64)
    imageView.constrainHeight(constant: 64)
    
    getButton.backgroundColor = UIColor(white: 0.95, alpha: 1)
    getButton.constrainWidth(constant: 80)
    getButton.constrainHeight(constant: 32)
    getButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    getButton.layer.cornerRadius = 32 / 2
    
    let stackView = UIStackView(arrangedSubviews: [imageView, VerticalStackView(arrangedSubviews: [nameLabel, companyLabel], spacing: 4), getButton])
    stackView.spacing = 16
    
    stackView.alignment = .center
    
    addSubview(stackView)
    stackView.fillSuperview()
    
    */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

import UIKit




