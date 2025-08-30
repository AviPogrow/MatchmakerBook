//
//  ShadchanGirlSubcategoryVC.swift
//  NasiShadchanHelper
//
//  Created by test on 5/22/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit

class ShadchanGirlSubcategoryVC: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    private let reuseIdentifier = "Cell"
    var selectedGroup: ShadchanGirlGroup!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = selectedGroup.titleString
        print("the state is \(selectedGroup.debugDescription)")
        
        collectionView.register(ShadchanGirlCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
 
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return  selectedGroup.arrayOfShadchanGirls.count
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ShadchanGirlCollectionViewCell
        //cell.backgroundColor = .yellow
        let currentGirl = selectedGroup.arrayOfShadchanGirls[indexPath.item]
        cell.girl = currentGirl
    
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let controller =  AddEditGirlViewController()
        var currentGirl = selectedGroup.arrayOfShadchanGirls[indexPath.item]
        controller.selectedShadchanGirl = currentGirl
        navigationController?.pushViewController(controller, animated: true)
       
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width /// 1 - 5
        
            return .init(width: width, height: 140)
        }
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return insets
    }

}


class ShadchanGirlCollectionViewCell: UICollectionViewCell {
    var girl: ShadchanGirl! {
        didSet {
            //let heightString = "\(girl.heightInFeet)" + "\'" + " " + "\(girl.heightInInches)"  + "\""
            nameLabel.text = girl!.girlLastName + " " + girl!.girlFirstName + " - "
           // + heightString
            nameLabel.font = .boldSystemFont(ofSize: 18)
            nameLabel.adjustsFontSizeToFitWidth = true
            
            //cityLabel.text =  "\(girl!.age)" + " yrs - " + girl!.cityOfResidence
            //ageLabel.text = "\(girl!.age)"
          //  seminaryLabel.text = "\(girl!.seminaryName)"
           // planLabel.text = "\(girl!.plan)"
            planLabel.textColor = .lightGray
            
           // guard let resumeImageUrl = girl?.documentDownloadURLString else { return }
            guard let profileImageUrl = girl?.photoImageURL else {return }
        
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
        iv.layer.cornerRadius = 42
        iv.clipsToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        //label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 14)
       // label.text = "Sara Green"
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
        
      let stackView = UIStackView(arrangedSubviews: [appIconImageView, VerticalStackView(arrangedSubviews: [nameLabel], spacing: 4), getButton])
        
        stackView.spacing = 16
        stackView.alignment = .center
        addSubview(stackView)
        stackView.fillSuperview(padding: UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20))
        self.backgroundColor = .systemGroupedBackground
        stackView.backgroundColor = .white
        
        stackView.layer.cornerRadius = 12
       stackView.clipsToBounds = true
        stackView.layer.shadowOpacity = 0.8
        stackView.layer.shadowRadius = 10
        stackView.layer.shadowOffset = .init(width: 0, height: 10)
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

