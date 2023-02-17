//
//  NasiDate.swift
//  NasiShadchanHelper
//
//  Created by test on 1/20/22.
//  Copyright © 2022 user. All rights reserved.
//

import Foundation
import Firebase

class NasiDate: NSObject {
    
    var  ref: DatabaseReference?
    var  key: String = ""
    var  boyFullName: String = ""
    var  boysAge: String = ""
    var  dateNumber: String = ""
    var  datingStatus: String = ""
    var  girlFullName: String  = ""
    var  girlAge: String = ""
    var  shadchanNotes: String = ""
    var  dateCreated: String = ""
    var  dateLastUpdate: Int   = 0
    var  nasiProgram: String = "" // N/A - Nasi - AY - Sefardim
    
    
    // initialize from a firebase snapshot coming down into app
    init(snapshot: DataSnapshot) {
    //let value = snapshot.value as! [String: AnyObject]
    guard  let value = snapshot.value! as? [String: AnyObject] else { return }
        
        // FB snapshot has a ref and key property
        self.ref = snapshot.ref
        self.key = snapshot.key
        
        let boyFullName = value["boyFullName"]  as? String
        let girlFullName = value["girlFullName"]  as? String
        let boysAge = value["boysAge"]  as? String
        let girlAge = value["girlAge"]  as? String
        let dateNumber = value["dateNumber"]  as? String
        let datingStatus = value["datingStatus"]  as? String
        let shadchanNotes = value["shadchanNotes"]  as? String
        let nasiProgram = value["nasiProgram"]  as? String
        let dateCreated = value["dateCreated"]  as? String
        let dateLastUpdate = value["dateLastUpdate"]  as? Int
        
        self.boyFullName = boyFullName ?? ""
        self.girlFullName = girlFullName ?? ""
        self.boysAge = boysAge ?? ""
        self.girlAge = girlAge ?? ""
        
        self.dateNumber = dateNumber ?? ""
        self.datingStatus = datingStatus ?? ""
        
        self.shadchanNotes = shadchanNotes ?? ""
        self.nasiProgram = nasiProgram ?? ""
        
        self.dateCreated = dateCreated ?? ""
        self.dateLastUpdate = dateLastUpdate ?? 0
        
        
    }

    // MARK: Initialize with user input data to send up
    // to firebase
    init(boyFullName: String, boysAge: String, dateNumber: String, datingStatus: String, girlFullName: String, girlAge: String, shadchanNotes: String, dateCreated: String, dateLastUpdate: Int, nasiProgram: String, key: String = "") {
        
        
      self.ref = nil
      self.key = key
      self.boyFullName = boyFullName
      self.boysAge = boysAge
      self.dateNumber = dateNumber
      self.datingStatus = datingStatus
      self.girlFullName = girlFullName
      self.girlAge = girlAge
      self.shadchanNotes = shadchanNotes
      self.dateCreated = dateCreated
      self.dateLastUpdate = dateLastUpdate
      self.nasiProgram = nasiProgram
        
    }
    
    // MARK: Convert GroceryItem to AnyObject
    func toAnyObject() -> Any {
      return [
        "boyFullName": boyFullName,
        "boysAge": boysAge,
        "dateNumber": dateNumber,
        "datingStatus" : datingStatus,
        "girlFullName" : girlFullName,
        "girlAge": girlAge,
        "shadchanNotes": shadchanNotes,
        "dateCreated": dateCreated,
        "dateLastUpdate": dateLastUpdate,
        "nasiProgram": nasiProgram
      ]
    }
    
    func createNewDateInFirebase() {
        let boyName = "Michel Jordan"
        let girlName = "Shprintza Gross"
        let datingStatus = "ended"
        let dateNumber = "4"
        let boyAge = "22"
        let girlAge = "22"
        let shadChanNotes = "Cute Couple"
        let nasiProgram = "Sefardim"
        let dateCreated = "\(Date())"
        let dateLastUpdate: Int = 0
        
        let newDate = NasiDate(boyFullName: boyName, boysAge: boyAge, dateNumber: dateNumber, datingStatus: datingStatus, girlFullName: girlName, girlAge: girlAge, shadchanNotes: shadchanNotes, dateCreated: dateCreated, dateLastUpdate: dateLastUpdate, nasiProgram: nasiProgram)
        
        let dateNodeRef = Database.database().reference(withPath: "NasiDatesList")

        //let groceryItemRef = self.ref.child(text.lowercased())
        dateNodeRef.setValue(newDate.toAnyObject())
    }

}
