//
//  ProfileView.swift
//  NasiShadchanHelper
//
//  Created by test on 2/24/23.
//  Copyright © 2023 user. All rights reserved.
//

import Foundation
import Firebase

class ProfileView: NSObject {
    
    var  ref: DatabaseReference?
    var  key: String = ""
    
    var timeStamp: String! = ""
    var girlID: String! = ""
    var shadchanID: String! = ""
    
    
    init(snapshot: DataSnapshot) {
    //let value = snapshot.value as! [String: AnyObject]
        guard  let value = snapshot.value! as? [String: String] else { return }
        
        let timeStamp = value["timeStamp"] ?? ""
        let girlID = value["girlID"] ?? ""
        let shadchanID = value["shadchanID"] ?? ""
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        
        self.timeStamp = timeStamp
        self.girlID = girlID
        self.shadchanID = shadchanID
    }
    
    
        
    
    
    init(timesStamp: String, girlID: String, shadchanID: String) {
        self.timeStamp = timesStamp
        self.girlID = girlID
        self.shadchanID = shadchanID
    }
    
    // MARK: Convert GroceryItem to AnyObject
    func toAnyObject() -> Any {
      return [
        "shachanID": shadchanID,
        "girlID": girlID,
        "timeStamp": timeStamp
        ]
        }
    
    
}

