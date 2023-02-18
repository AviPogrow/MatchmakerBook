//
//  AdminLoginController.swift
//  NasiShadchanHelper
//
//  Created by test on 2/18/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit

class AdminLoginController: UITableViewController {
    
    
    @IBOutlet weak var loginTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
    }

    @IBAction func submitTapped(_ sender: Any) {
        let adminController = storyboard?.instantiateViewController(withIdentifier: "AdminPanelVC")
        if loginTextField.text == "fdoddi" {
            self.navigationController?.pushViewController(adminController!, animated: true)
        }
    }
    
}
