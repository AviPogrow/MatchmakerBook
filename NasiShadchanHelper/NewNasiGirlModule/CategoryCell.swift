//
//  CategoryCell.swift
//  NasiShadchanHelper
//
//  Created by test on 12/31/22.
//  Copyright © 2022 user. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    var currentImageID: String! {
        didSet {
            imageView.image = UIImage(named: currentImageID)
        }
    }
    
    var category: String! {
        didSet {
           categoryLabel.text = category
            
            
        }
    }
    fileprivate let gradientLayer = CAGradientLayer()
    let imageView = UIImageView()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Test"
        return label
    }()
    
    var stackView: UIStackView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.image = #imageLiteral(resourceName: "Abady")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .black
        
        categoryLabel.backgroundColor = .darkGray
        categoryLabel.numberOfLines = 2
        categoryLabel.textColor = .white
        
        
        //stackView =
            VerticalStackView(arrangedSubviews: [imageView, categoryLabel])
        
        //stackView.distribution = .fillEqually
        //stackView.backgroundColor = UIColor.blue
        addSubview(imageView)
        imageView.fillSuperview()
        imageView.addSubview(categoryLabel)
      
        //stackView.fillSuperview()
        
        
       
    }
    
    override func layoutSubviews() {
        // in here you know what you CardView frame will be
       // gradientLayer.frame = self.frame
        categoryLabel.frame = CGRect(x: imageView.frame.minX, y: imageView.frame.minY, width: imageView.bounds.width, height: 60)
    }
    
    override func didMoveToSuperview() {
        //stackView.layer.addSublayer(gradientLayer)
       // setupGradientLayer()
        //gradientLayer.frame = self.frame
    }
    
    fileprivate func setupGradientLayer() {
        // how we can draw a gradient with Swift
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.1]
        // self.frame is actually zero frame
        
        //layer.addSublayer(gradientLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
