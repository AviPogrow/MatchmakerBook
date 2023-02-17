//
//  ShadchanGirl.swift
//  NasiShadchanHelper
//
//  Created by test on 11/15/22.
//  Copyright © 2022 user. All rights reserved.
//


import Foundation
import Firebase

class ShadchanGirl: NSObject {
    var  ref: DatabaseReference?
    var  key: String = ""
    
    var girlLastName = ""
    var girlFirstName = ""
    //var dob: Date?
    var dobIntervalString = ""
    var calculatedAge = ""
    var girlHeight = ""
    
    var girlCell = ""
    var sendResumeEmail = ""
    var sendResumeText = ""
    
    var categories: [String] = []
    var status = "available"
    
    var dateCreated = ""
    var  dateLastUpdate: Int   = 0
    
    var shadchanNotes = ""
    var notesImageURL = ""
    var resumeImageURL = ""
    var photoImageURL = ""
    
    
    init(snapshot: DataSnapshot) {
    //let value = snapshot.value as! [String: AnyObject]
        guard  let value = snapshot.value! as? [String: AnyObject] else { return }
        
        // FB snapshot has a ref and key property
        self.ref = snapshot.ref
        self.key = snapshot.key
        
      
        let girlCell = value["girlCell"] as? String
        let girlLastName = value["girlLastName"] as? String
        let girlFirstName = value["girlFirstName"] as? String
        var girlHeight = value["girlHeight"] as? String
        
        
        let dateCreated = value["dateCreated"] as? String
        let dateLastUpdate = value["dateLastUpdate"]  as? Int
        //let dob = value["dob"] as? Date
        let dobIntervalString = value["dobIntervalString"] as? String
        let calculatedAge = value["calculatedAge"] as? String
        
        
        let sendResumeEmail = value["sendResumeEmail"] as? String
        let sendResumeText = value["sendResumeText"] as? String
        let categories = value["categories"] as? [String]
        
        let shadchanNotes = value["shadchanNotes"] as? String
        let notesImageURL = value["notesImageURL"] as? String
        let resumeImageURL = value["resumeImageURL"] as? String
        let photoImageURL = value["photoImageURL"] as? String
       
        
        self.girlFirstName = girlFirstName ?? ""
        self.girlLastName = girlLastName ?? ""
        self.girlCell = girlCell ?? ""
        self.girlHeight = girlHeight ?? ""
         
        self.dateCreated = dateCreated ?? ""
        self.dobIntervalString = dobIntervalString ?? ""
        
        
        self.dateLastUpdate = dateLastUpdate ?? 0
       // self.dob = dob
        self.calculatedAge = calculatedAge ?? ""
        self.sendResumeEmail = sendResumeEmail ?? ""
        self.sendResumeText = sendResumeText ?? ""
        self.categories = categories ?? [String]()
        self.shadchanNotes = shadchanNotes ?? ""
        self.notesImageURL = notesImageURL ?? ""
        self.resumeImageURL = resumeImageURL ?? ""
        self.photoImageURL = photoImageURL ?? ""
    }
    
    // MARK: Initialize with data from user input
    init(girlCell: String, girlLastName: String,girlFirstName:String,calculatedAge: String, dobIntervalString:String,  dateCreated: String,dateLastUpdate: Int, girlHeight: String, sendResumeEmail: String,sendResumeText:String,categories: [String],shadchanNotes: String, notesImageURL: String,resumeImageURL:String, photoImageURL: String, key: String = "") {
        
        
      self.ref = nil
      self.key = key
      
      self.girlCell = girlCell
      self.girlFirstName = girlFirstName
      self.girlLastName = girlLastName
    
      self.dateCreated = dateCreated
      self.dobIntervalString = dobIntervalString
        self.dateLastUpdate = dateLastUpdate
        
     // self.dob = dob
      self.calculatedAge = calculatedAge
      self.girlHeight = girlHeight
    
    
      self.sendResumeEmail = sendResumeEmail
      self.sendResumeText = sendResumeText
    
      self.categories = categories
        self.shadchanNotes = shadchanNotes
      self.notesImageURL = notesImageURL
      self.resumeImageURL = resumeImageURL
      self.photoImageURL = photoImageURL
        
    }
    
    // MARK: Convert GroceryItem to AnyObject
    func toAnyObject() -> Any {
      return [
        "girlCell": girlCell,
        "girlLastName": girlLastName,
        "girlFirstName": girlFirstName,
        "girlHeight": girlHeight,
        "dateCreated": dateCreated,
        "dateLastUpdate": dateLastUpdate,
        "dobIntervalString": dobIntervalString,
        "calculatedAge": calculatedAge,
        "sendResumeEmail": sendResumeEmail,
        "sendResumeText": sendResumeText,
        "categories": categories,
        "shadchanNotes": shadchanNotes,
        "notesImageURL": notesImageURL,
        "resumeImageURL": resumeImageURL,
        "photoImageURL": photoImageURL
      ]
    }
    
    func addShadchanGirl() {
        
        let newGirl = ShadchanGirl(girlCell: "2223334545", girlLastName: "Pogrow", girlFirstName: "Shayna", calculatedAge: "33", dobIntervalString: "", dateCreated: "7/7/21", dateLastUpdate: 66, girlHeight: "5'3", sendResumeEmail: "rpogrow@gmail.com", sendResumeText: "3234445656", categories: ["Yeshivish","Chasidish"], shadchanNotes: "great guy", notesImageURL: "", resumeImageURL: "", photoImageURL: "")
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let shadchanGirlNodeRef = Database.database().reference().child("ShadchanGirlsList").child(uid)
        
        let ref = shadchanGirlNodeRef.childByAutoId()
        
        ref.setValue(newGirl.toAnyObject())
        
    }
  
}
