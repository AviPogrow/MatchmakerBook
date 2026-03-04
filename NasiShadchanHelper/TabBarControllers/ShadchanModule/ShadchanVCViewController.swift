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
    @IBOutlet weak var AYGirlsButton: UIButton!
    
    @IBOutlet weak var myMatches: UIButton!
    @IBOutlet weak var shadchanProfileLabel: UILabel!
    
    
    
  let masterUsersListRef =
    Database.database().reference().child("NasiShadchanUserList")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //myMatches.isEnabled = false
        shadchanProfileLabel.text = "My Singles"
        //fetchListAndCheck()
    }
    /*
    // does current user have accesss?
    // fetch current user and check access property
    func fetchListAndCheck()  {
        
        self.AYGirlsButton.isEnabled = true
        guard let myId = UserInfo.curentUser?.id else {return}
        
     masterUsersListRef.observe(.value, with: { snapshot in
            
    var usersWithAccessArray = [ShadchanUser]()
    
   for child in snapshot.children {
    let snapshot = child as? DataSnapshot
    let shadchanUser = ShadchanUser(snapshot: snapshot!)
            
    let shadchanID = shadchanUser.key
    
       print(shadchanUser.key)
       print(shadchanUser.privateGirlsListAccess)
        print(shadchanUser.shadchanEmail)
       
      // if shadchanID == myId && shadchanUser.privateGirlsListAccess == "yes" {
         
        //DispatchQueue.main.async(execute: {
       // self.AYGirlsButton.isEnabled = true
        //})
     }
    }
})
     
   //}
     */
}
