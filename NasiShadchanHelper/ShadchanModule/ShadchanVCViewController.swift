//
//  ShadchanVCViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 2/17/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import Firebase

class ShadchanVCViewController: UIViewController {
    
    
    var hasAccess = "false"
    @IBOutlet weak var myGirlsButton: UIButton!
    
    @IBOutlet weak var myMatches: UIButton!
    @IBOutlet weak var shadchanProfileLabel: UILabel!
    
    
    
  let masterUsersListRef =
    Database.database().reference().child("NasiShadchanUserList")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //myMatches.isEnabled = false
        shadchanProfileLabel.text = "My Singles"
        
    }
    
    // does current user have accesss?
    // fetch current user and check access property
    func fetchListAndCheck()  {
        
        self.myGirlsButton.isEnabled = false
        guard let myId = UserInfo.curentUser?.id else {return}
        
     masterUsersListRef.observe(.value, with: { snapshot in
            
            var usersWithAccessArray: [ShadchanUser] = []
            
            for child in snapshot.children {
             let snapshot = child as? DataSnapshot
             let shadchanUser = ShadchanUser(snapshot: snapshot!)
              
            let currentID = "\(shadchanUser.shadchanUserID)"
            print("currentShadchanId is \(currentID)")
            print("myID is \(myId)")
            let testy = "true"
            if testy == "true"  {
                DispatchQueue.main.async(execute: {
                self.myGirlsButton.isEnabled = true
                })
            }
          }
     //   }
         
    })
    }
   
}
