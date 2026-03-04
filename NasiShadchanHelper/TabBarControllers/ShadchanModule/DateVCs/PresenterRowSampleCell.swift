//
//  PresenterRowSampleCell.swift
//  PresenterRowSample
//
//  Created by Alfredo Luco on 13-03-20.
//  Copyright © 2020 Alfredo Luco. All rights reserved.
//

import UIKit
import Eureka

public class PresenterRowSampleCell: PushSelectorCell<String>{
    
    //MARK: - IBOutlets
    var stockedLabel:UILabel!
    
    var imageViewIcon:UIImageView!
    
    override public func setup() {
        super.setup()
    }
    
    override public func update() {
        super.update()
        if let value = row.value{
            self.stockedLabel.text = "test"
            self.imageViewIcon.image = UIImage(named: "Cohen")
        }
    }
    
}
