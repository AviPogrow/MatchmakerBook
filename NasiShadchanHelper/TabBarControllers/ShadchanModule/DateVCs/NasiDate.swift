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
    var  boyFirstName: String = ""
    var  boyLastName: String = ""
    var  boyDobString: String = ""
    var  boysAge: String  = ""
    var  boyKey: String = ""
    var  boyCellNumber: String = ""
    
    var  girlFullName: String  = ""
    var  girlFirstName: String = ""
    var  girlLastName: String = ""
    var  girlDobString: String = ""
    var  girlAge: String  = ""
    var  girlKey: String = ""
    var  girlCellNumber: String = ""

    
    var  dateNumber: String = ""
    var  datingStatus: String = ""
   
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
        
        //let boyFullName = value["boyFullName"]  as? String
        let boyFirstName = value["boyFirstName"] as? String
        let boyLastName = value["boyLastName"] as? String
        let boyFullName = value["boyFullName"] as? String
        let boyDobString = value["boyDobString"] as? String
        let boysAge = value["boysAge"] as? String
        let boyKey = value["boyKey"] as? String
        let boyCellNumber  = value["boyCellNumber"] as? String
        
        
        let girlFullName = value["girlFullName"]  as? String
        let girlFirstName = value["girlFirstName"] as? String
        let girlLastName = value["girlLastName"] as? String
        let girlDobString = value["girlDobString"] as? String
        let girlAge = value["girlAge"] as? String
        let girlKey = value["girlKey"] as? String
        let girlCellNumber = value["girlCellNumber"] as? String
        

        
        let dateNumber = value["dateNumber"]  as? String
        let datingStatus = value["datingStatus"]  as? String
        let shadchanNotes = value["shadchanNotes"]  as? String
        let nasiProgram = value["nasiProgram"]  as? String
        let dateCreated = value["dateCreated"]  as? String
        let dateLastUpdate = value["dateLastUpdate"]  as? Int
        
        
        self.boyFirstName = boyFirstName ?? ""
        self.boyLastName = boyLastName ?? ""
        self.boyFullName = boyFullName ?? ""
        self.boyKey = boyKey ?? ""
        self.boyCellNumber = boyCellNumber ?? ""
        self.boyDobString = boyDobString ?? ""
        self.boysAge = boysAge ?? ""
        
        
        self.girlFullName = girlFullName ?? ""
        self.girlFirstName = girlFirstName ?? ""
        self.girlLastName = girlLastName ?? ""
        self.girlKey = girlKey ?? ""
        self.girlCellNumber = girlCellNumber ?? ""
        self.girlDobString = girlDobString ?? ""
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
    init(boyFirstName: String,boyLastName: String, boyFullName: String, boyKey: String,boyCellNumber:String, boyDobString: String,boysAge: String, dateNumber: String, datingStatus: String, girlFirstName: String, girlLastName: String,girlFullName: String, girlKey: String,girlDobString: String,girlAge:String, girlCellNumber: String, shadchanNotes: String, dateCreated: String, dateLastUpdate: Int, nasiProgram: String, key: String = "") {
        
        
      self.ref = nil
      self.key = key
      self.boyFirstName = boyFirstName
      self.boyLastName = boyLastName
      self.boyFullName = boyFullName
      self.boyKey = boyKey
      self.boyDobString = boyDobString
      self.boysAge = boysAge
      self.boyCellNumber = boyCellNumber
        
        
        
      self.dateNumber = dateNumber
      self.datingStatus = datingStatus
        
      self.girlFirstName = girlFirstName
      self.girlLastName = girlLastName
        self.girlFullName = girlFullName
      self.girlDobString = girlDobString
        self.girlAge = girlAge
        self.girlCellNumber = girlCellNumber
        self.girlKey = girlKey
        
      self.shadchanNotes = shadchanNotes
      self.dateCreated = dateCreated
      self.dateLastUpdate = dateLastUpdate
      self.nasiProgram = nasiProgram
        
    }
    
    // MARK: Convert GroceryItem to AnyObject
    func toAnyObject() -> Any {
      return [
        "boyFirstName": boyFirstName,
        "boyLastName": boyLastName,
        "boyFullName": boyFullName,
        "boyDobString": boyDobString,
        "boysAge": boysAge,
        "boyCellNumber": boyCellNumber,
        "boyKey": boyKey,
        "dateNumber": dateNumber,
        "datingStatus" : datingStatus,
        "girlFirstName" : girlFirstName,
        "girlLastName": girlLastName,
        "girlFullName": girlFullName,
        "girlDobString": girlDobString,
        "girlAge": girlAge,
        "girlCellNumber": girlCellNumber,
        "girlKey": girlKey,
        "shadchanNotes": shadchanNotes,
        "dateCreated": dateCreated,
        "dateLastUpdate": dateLastUpdate,
        "nasiProgram": nasiProgram
      ]
    }
    
    /*
    func createNewDateInFirebase() {
        let boyFirstName = "Michel"
        let boyLastName = "Jordan"
        let girlFirstName = "Shprintza"
        let girlLastName = "Gross"
        let datingStatus = "ended"
        let dateNumber = "4"
        let boysAge = "22"
        let girlAge = "22"
        let shadChanNotes = "Cute Couple"
        let nasiProgram = "Sefardim"
        let dateCreated = "\(Date())"
        let dateLastUpdate: Int = 0
        
        let newDate = NasiDate(boyFirstName: boyFirstName,
                               boyLastName: boyLastName,
                               boyFullName: boyFullName,
                               boysAge: boysAge,
                               dateNumber: dateNumber,
                               datingStatus: datingStatus,
                               girlFirstName: girlFirstName,
                               girlLastName: girlLastName,
                               girlFullName: girlFullName,
                               girlAge: girlAge,
                               shadchanNotes: shadchanNotes,
                               dateCreated: dateCreated,
                               dateLastUpdate: dateLastUpdate,
                               nasiProgram: nasiProgram)
        
        let dateNodeRef = Database.database().reference(withPath: "NasiDatesList")

        //let groceryItemRef = self.ref.child(text.lowercased())
        dateNodeRef.setValue(newDate.toAnyObject())
    }
*/
}
