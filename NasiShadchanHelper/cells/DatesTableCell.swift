//
//  DatesTableCell.swift
//  NasiShadchanHelper
//
//  Created by test on 1/22/22.
//  Copyright © 2022 user. All rights reserved.
//

import UIKit

class DatesTableCell: UITableViewCell {

    @IBOutlet weak var boysNameLabel: UILabel!
    
    
    @IBOutlet weak var girlsNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
