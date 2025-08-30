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
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    override func viewDidLoad() {
        super.viewDidLoad()

      //setupBlurView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBlurView()
    }
    
    fileprivate func setupBlurView() {
        //visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        visualEffectView.frame = view.bounds
        view.addSubview(visualEffectView)
        //visualEffectView.fillSuperview()
        visualEffectView.alpha = 1
        
    }
    @IBAction func submitTapped(_ sender: Any) {
        let adminController = storyboard?.instantiateViewController(withIdentifier: "AdminPanelVC")
        if loginTextField.text == "fdoddi" {
            self.navigationController?.pushViewController(adminController!, animated: true)
        }
    }
    
}
