//
//  CategoryHeaderCollectionReusableView.swift
//  NasiShadchanHelper
//
//  Created by test on 12/5/22.
//  Copyright © 2022 user. All rights reserved.
//

import UIKit

class CategoryHeader: UICollectionReusableView {
    let headerLabel = UILabel()
    
    var category: String! {
        didSet {
           headerLabel.text = category
            
        }
    }
        
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       
        //backgroundColor = .yellow
        
        //headerLabel.backgroundColor = .lightGray
        addSubview(headerLabel)
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        headerLabel.fillSuperview(padding: insets)
       
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
