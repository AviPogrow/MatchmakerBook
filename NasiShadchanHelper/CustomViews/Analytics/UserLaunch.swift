//
//  UserLaunch.swift
//  NasiShadchanHelper
//
//  Created by test on 2/24/23.
//  Copyright © 2023 user. All rights reserved.
//

import Foundation
import Firebase

class UserLaunch: NSObject {
    var  ref: DatabaseReference?
    var  key: String = ""
    
    var timeStamp: String! = ""
    
    var shadchanID: String! = ""
    
    init(timesStamp: String,shadchanID: String) {
        self.timeStamp = timesStamp
        
        self.shadchanID = shadchanID
    }
    
    // MARK: Convert GroceryItem to AnyObject
    func toAnyObject() -> Any {
      return [
        "shachanID": shadchanID,
        "timeStamp": timeStamp
        ]
        }
}
