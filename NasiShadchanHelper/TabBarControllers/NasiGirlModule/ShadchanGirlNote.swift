//
//  ShadchanGirlNote.swift
//  NasiShadchanHelper
//
//  Created by test on 2/9/22.
//  Copyright © 2022 user. All rights reserved.
//

import Foundation
import Firebase

class ShadchanGirlNote: NSObject {
    
    var  ref: DatabaseReference?
    var  key: String = ""
    
    var ShachanID: String = ""
    var ShadchanEmail: String = ""
    var ShadchanFirstName: String = ""
    var ShadchanLastName: String = ""
    var girlFirstName: String = ""
    var girlLastName: String = ""
    var girlRef: String = ""
    var girlUID: String = ""
    var notesImageURL: String = ""
    var notesTextString: String  = ""
    var timeStamp: String = ""
    
    init(snapshot: DataSnapshot) {
    //let value = snapshot.value as! [String: AnyObject]
    guard  let value = snapshot.value! as? [String: String] else { return }
        
        // FB snapshot has a ref and key property
        self.ref = snapshot.ref
        self.key = snapshot.key
        
        let ShachanID = value["ShachanID"] ?? ""
        let ShadchanEmail = value["ShadchanEmail"] ?? ""
        let ShadchanFirstName = value["ShadchanFirstName"] ?? ""
        let ShadchanLastName = value["ShadchanLastName"] ?? ""
        
        let girlFirstName = value["girlFirstName"] ?? ""
        let girlLastName = value["girlLastName"] ?? ""
        let girlRef = value["girlRef"] ?? ""
        let girlUID = value["girlUID"] ?? ""
        
        let notesImageURL = value["notesImageURL"] ?? ""
        let notesTextString = value["notesTextString"] ?? ""
        let timeStamp = value["timeStamp"] ?? ""
        
        self.ShachanID = ShachanID
        self.ShadchanEmail = ShadchanEmail
        self.ShadchanFirstName = ShadchanFirstName
        self.ShadchanLastName = ShadchanLastName
        
        self.girlFirstName = girlFirstName
        self.girlLastName = girlLastName
        self.girlRef = girlRef
        self.girlUID = girlUID
        
        self.notesImageURL = notesImageURL
        self.notesTextString = notesTextString
        self.timeStamp = timeStamp
    }
    
    // MARK: Initialize with Raw Data
    init(ShachanID: String, ShadchanEmail: String, ShadchanFirstName: String, ShadchanLastName: String, girlFirstName: String, girlLastName: String, girlRef: String, girlUID: String, notesImageURL: String, notesTextString: String,timeStamp: String, key: String = "") {
        
        
      self.ref = nil
      self.key = key
        
      self.ShachanID = ShachanID
      self.ShadchanEmail = ShadchanEmail
      self.ShadchanFirstName = ShadchanFirstName
      self.ShadchanLastName = ShadchanLastName
        
      self.girlFirstName = girlFirstName
      self.girlLastName = girlLastName
      self.girlRef = girlRef
      self.girlUID = girlUID
        
      self.notesImageURL = notesImageURL
      self.notesTextString = notesTextString
        
    }
    
    // MARK: Convert GroceryItem to AnyObject
    func toAnyObject() -> Any {
      return [
        "ShachanID": ShachanID,
        "ShadchanEmail": ShadchanEmail,
        "ShadchanFirstName": ShadchanFirstName,
        "ShadchanLastName" : ShadchanLastName,
        "girlFirstName" : girlFirstName,
        "girlLastName": girlLastName,
        "girlRef": girlRef,
        "girlUID": girlUID,
        "notesImageURL": notesImageURL,
        "notesTextString": notesTextString
      ]
    }
    
    
        
}
    
    
    
    
    

    
