//
//  BoyCollectionViewCell.swift
//  NasiShadchanHelper
//
//  Created by test on 5/6/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit

class BoyCollectionViewCell: UICollectionViewCell {
    
        var boy: NasiBoy! {
            didSet {
                
                //let heightString = "\(girl.heightInFeet)" + "\'" + " " + "\(girl.heightInInches)"  + "\""
                nameLabel.text = boy!.boyLastName + " " + boy!.boyFirstName //+ " - "
               // + heightString
                cityLabel.text  =  boy.city 
                
                //ageLabel.text = "\(girl!.age)"
                
                 
                 /*
                seminaryLabel.text = "\(girl!.seminaryName)"
                planLabel.text = "\(girl!.plan)"
                planLabel.textColor = .lightGray
                
                guard let resumeImageUrl = girl?.documentDownloadURLString else { return }
                guard let profileImageUrl = girl?.imageDownloadURLString else {return }
            
                appIconImageView.loadImageFromUrl(strUrl: profileImageUrl, imgPlaceHolder: "")
                 */
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
            iv.layer.cornerRadius = 42
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
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            appIconImageView.backgroundColor = .black
            appIconImageView.constrainWidth(constant: 84)
            appIconImageView.constrainHeight(constant: 84)
            
            getButton.backgroundColor = UIColor(white: 0.95, alpha: 1)
            getButton.constrainWidth(constant: 80)
            getButton.constrainHeight(constant: 32)
            getButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            getButton.layer.cornerRadius = 32 / 2
            
            let stackView = UIStackView(arrangedSubviews: [nameLabel,cityLabel, getButton])
            stackView.axis = .horizontal
            
            //stackView.spacing = 16
            
            stackView.alignment = .center
            
            addSubview(stackView)
            stackView.fillSuperview(padding: UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20))
            self.backgroundColor = .systemGroupedBackground
            stackView.backgroundColor = .white
            
            stackView.layer.cornerRadius = 12
            //stackView.layer.borderWidth = 0.5
            //stackView.layer.borderColor = UIColor.red.cgColor
            stackView.clipsToBounds = true
            
            stackView.layer.shadowOpacity = 0.8
            stackView.layer.shadowRadius = 10
            stackView.layer.shadowOffset = .init(width: 0, height: 10)
            
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
    }

