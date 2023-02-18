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
    
    
    var hasAccess = false
    @IBOutlet weak var myGirlsButton: UIButton!
    
    @IBOutlet weak var myMatches: UIButton!
    
   
  let masterUsersListRef = Database.database().reference().child("NasiShadchanUserList")
   

    override func viewDidLoad() {
        super.viewDidLoad()
        hasAccess = fetchListAndCheck()
    }
    
    // does current user have accesss?
    // fetch current user and check access property
    func fetchListAndCheck() -> Bool {
        
        
    guard let myId = UserInfo.curentUser?.id else {
        return false
        
    }
        
     masterUsersListRef.observe(.value, with: { snapshot in
            
            var usersWithAccessArray: [ShadchanUser] = []
            
            for child in snapshot.children {
            let snapshot = child as? DataSnapshot
            let shadchanUser = ShadchanUser(snapshot: snapshot!)
             
              // if we have the current user then
              // find out permission yes/no
              if shadchanUser.shadchanUserID == myId {
                
                //if shadchanUser.hasAccess == true {
                // give them acceess
               }
            }
     })
        return hasAccess
    }

}
