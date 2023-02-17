//
//  NasiBoy.swift
//  NasiShadchanHelper
//
//  Created by test on 12/31/21.
//  Copyright © 2021 user. All rights reserved.
//

import Foundation
import Firebase

class NasiBoy: NSObject {
    
    var  ref: DatabaseReference?
    var  key: String = ""
    

    var boyLastName = ""
    var boyFirstName = ""
    //var dob: Date?
    var dobIntervalString = ""
    var calculatedAge = ""
    var boyHeight = ""
    
    var boyCell = ""
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
        
      
        let boyCell = value["boyCell"] as? String
        let boyLastName = value["boyLastName"] as? String
        let boyFirstName = value["boyFirstName"] as? String
        
        
        let dateCreated = value["dateCreated"] as? String
        let dateLastUpdate = value["dateLastUpdate"]  as? Int
        //let dob = value["dob"] as? Date
        let dobIntervalString = value["dobIntervalString"] as? String
        let calculatedAge = value["calculatedAge"] as? String
        var boyHeight = value["boyHeight"] as? String
        
        let sendResumeEmail = value["sendResumeEmail"] as? String
        let sendResumeText = value["sendResumeText"] as? String
        let categories = value["categories"] as? [String]
        let status = value["status"] as? String
        
        let shadchanNotes = value["shadchanNotes"] as? String
        let notesImageURL = value["notesImageURL"] as? String
        let resumeImageURL = value["resumeImageURL"] as? String
        let photoImageURL = value["photoImageURL"] as? String
       
        
        self.boyFirstName = boyFirstName ?? ""
        self.boyLastName = boyLastName ?? ""
        self.boyCell = boyCell ?? ""
         
        self.dateCreated = dateCreated ?? ""
        self.dobIntervalString = dobIntervalString ?? ""
        
        
        self.dateLastUpdate = dateLastUpdate ?? 0
       // self.dob = dob
        self.calculatedAge = calculatedAge ?? ""
        self.boyHeight = boyHeight ?? ""
        self.sendResumeEmail = sendResumeEmail ?? ""
        self.sendResumeText = sendResumeText ?? ""
        self.categories = categories ?? [String]()
        self.status = status ?? "available"
        self.shadchanNotes = shadchanNotes ?? ""
        self.notesImageURL = notesImageURL ?? ""
        self.resumeImageURL = resumeImageURL ?? ""
        self.photoImageURL = photoImageURL ?? ""
    }
    
  
    // MARK: Initialize with data from user input
    init(boyCell: String, boyLastName: String,boyFirstName:String,calculatedAge: String, dobIntervalString:String,  dateCreated: String,dateLastUpdate: Int, boyHeight: String, sendResumeEmail: String,sendResumeText:String,categories: [String],status: String, shadchanNotes: String, notesImageURL: String,resumeImageURL:String, photoImageURL: String, key: String = "") {
        
        
      self.ref = nil
      self.key = key
      
      self.boyCell = boyCell
      self.boyFirstName = boyFirstName
      self.boyLastName = boyLastName
    
      self.dateCreated = dateCreated
      self.dobIntervalString = dobIntervalString
        self.dateLastUpdate = dateLastUpdate
        
     // self.dob = dob
      self.calculatedAge = calculatedAge
      self.boyHeight = boyHeight
    
    
      self.sendResumeEmail = sendResumeEmail
      self.sendResumeText = sendResumeText
    
      self.categories = categories
        self.status = status
        self.shadchanNotes = shadchanNotes
      self.notesImageURL = notesImageURL
      self.resumeImageURL = resumeImageURL
      self.photoImageURL = photoImageURL
        
    }
    
    // MARK: Convert GroceryItem to AnyObject
    func toAnyObject() -> Any {
      return [
        "boyCell": boyCell,
        "boyLastName": boyLastName,
        "boyFirstName": boyFirstName,
        "boyHeight": boyHeight,
        "dateCreated": dateCreated,
        "dateLastUpdate": dateLastUpdate,
        "dobIntervalString": dobIntervalString,
        "calculatedAge": calculatedAge,
        "sendResumeEmail": sendResumeEmail,
        "sendResumeText": sendResumeText,
        "categories": categories,
        "status": status,
        "shadchanNotes": shadchanNotes,
        "notesImageURL": notesImageURL,
        "resumeImageURL": resumeImageURL,
        "photoImageURL": photoImageURL
      ]
    }
    

    
    
    func createNewDateInFirebase() {
        
        let boyName = "Joe Biden"
        let girlName = "Jill Rogers"
        let datingStatus = "Active"
        let dateNumber = "4"
        let boyAge = "22"
        let girlAge = "22"
        let shadchanNotes = "Cute Couple"
        let nasiProgram = "Sefardim"
        let dateCreated = "\(Date())"
        let dateLastUpdate: Int = 0
        
        let newDate = NasiDate(boyFullName: boyName, boysAge: boyAge, dateNumber: dateNumber, datingStatus: datingStatus, girlFullName: girlName, girlAge: girlAge, shadchanNotes: shadchanNotes, dateCreated: dateCreated, dateLastUpdate: dateLastUpdate, nasiProgram: nasiProgram)
        
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let dateNodeRef = Database.database().reference().child("NasiDatesList").child(uid)
        
        let ref = dateNodeRef.childByAutoId()
        //let groceryItemRef = self.ref.child(text.lowercased())
        ref.setValue(newDate.toAnyObject())
    }
    
    
    
    
    }
    

