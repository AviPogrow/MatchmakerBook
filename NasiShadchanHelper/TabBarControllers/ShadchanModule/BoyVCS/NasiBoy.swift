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
    var boyCell = ""
    
    //var dob: Date?
    var ageEntered: Int = 0
    var dobIntervalString = ""
    
    
    var city = ""
    var boyHeight = ""
    var sendResumeEmail = ""
    var sendResumeText = ""
    
    var categories: [String] = []
    var status = "available"

    var dateCreated = ""
    var  dateLastUpdate: Int   = 0
    
    var datingHistory = ""
    var shadchanNotes = ""
    var shadchanNotesNew = ""
    var notesImageURL = ""
    var resumeImageURL = ""
    var photoImageURL = ""
    
    
    
    init(snapshot: DataSnapshot) {
        super.init()
        //let value = snapshot.value as! [String: AnyObject]
        guard  let value = snapshot.value! as? [String: AnyObject] else { return }
        
        // FB snapshot has a ref and key property
        self.ref = snapshot.ref
        self.key = snapshot.key
        
        
        let boyCell = value["boyCell"] as? String
        let boyLastName = value["boyLastName"] as? String
        let boyFirstName = value["boyFirstName"] as? String
        let city = value["city"] as? String
        
        
        let dateCreated = value["dateCreated"] as? String
        let dateLastUpdate = value["dateLastUpdate"]  as? Int
        //let dob = value["dob"] as? Date
        let ageEntered = value["ageEntered"] as? Int
        let dobIntervalString = value["dobIntervalString"] as? String
        
        var boyHeight = value["boyHeight"] as? String
        
        let sendResumeEmail = value["sendResumeEmail"] as? String
        let sendResumeText = value["sendResumeText"] as? String
        let categories = value["categories"] as? [String]
        let status = value["status"] as? String
        
        let shadchanNotes = value["shadchanNotes"] as? String
        let shadchanNotesNew = value["shadchanNotesNew"] as? String
        let datingHistory = value["datingHistory"] as? String
        let notesImageURL = value["notesImageURL"] as? String
        let resumeImageURL = value["resumeImageURL"] as? String
        let photoImageURL = value["photoImageURL"] as? String
        
        
        self.boyFirstName = boyFirstName ?? "N/A"
        self.boyLastName = boyLastName ?? ""
        self.city = city ?? ""
        self.boyCell = boyCell ?? "N/A"
        
        self.ageEntered = ageEntered ?? 0
        self.dateCreated = dateCreated ?? ""
        self.dobIntervalString = dobIntervalString ?? ""
        
        
        self.dateLastUpdate = dateLastUpdate ?? 0
        // self.dob = dob
        
        self.boyHeight = boyHeight ?? ""
        self.sendResumeEmail = sendResumeEmail ?? "N/A"
        self.sendResumeText = sendResumeText ?? "N/A"
        self.categories = categories ?? [String]()
        self.status = status ?? "available"
        self.shadchanNotesNew = shadchanNotesNew ?? ""
        self.shadchanNotes = shadchanNotes ?? ""
        self.datingHistory = datingHistory ?? ""
        self.notesImageURL = notesImageURL ?? ""
        self.resumeImageURL = resumeImageURL ?? ""
        self.photoImageURL = photoImageURL ?? ""
        
        self.dobIntervalString = dobIntervalString ?? ""
        let nowString = "\(Date())"
        let age = calculateAgeFrom(dobString: dobIntervalString ?? nowString)
        
        
    }
    
  
    // MARK: Initialize with data from user input
    init(boyCell: String, boyLastName: String,boyFirstName:String,city:String, dobIntervalString:String,  dateCreated: String,dateLastUpdate: Int, boyHeight: String, sendResumeEmail: String,sendResumeText:String,categories: [String],status: String, shadchanNotes: String,shadchanNotesNew: String, datingHistory:String, notesImageURL: String,resumeImageURL:String, photoImageURL: String, key: String = "") {
        
        
      self.ref = nil
      self.key = key
      
      self.boyCell = boyCell
      self.boyFirstName = boyFirstName
      self.boyLastName = boyLastName
      self.city = city
    
      self.dateCreated = dateCreated
      self.dobIntervalString = dobIntervalString
        self.dateLastUpdate = dateLastUpdate
        
     // self.dob = dob
      
      self.boyHeight = boyHeight
    
    
      self.sendResumeEmail = sendResumeEmail
      self.sendResumeText = sendResumeText
    
      self.categories = categories
        self.status = status
        self.shadchanNotes = shadchanNotes
        self.shadchanNotesNew = shadchanNotesNew
        self.datingHistory  = datingHistory
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
        "city": city,
        "boyHeight": boyHeight,
        "ageEntered": ageEntered,
        "dateCreated": dateCreated,
        "dateLastUpdate": dateLastUpdate,
        "dobIntervalString": dobIntervalString,
        
        "sendResumeEmail": sendResumeEmail,
        "sendResumeText": sendResumeText,
        "categories": categories,
        "status": status,
        "shadchanNotes": shadchanNotes,
        "shadchanNotesNew": shadchanNotesNew,
        "datingHistory": datingHistory,
        "notesImageURL": notesImageURL,
        "resumeImageURL": resumeImageURL,
        "photoImageURL": photoImageURL
      ]
    }
    
    func calculateAgeFrom(dobString: String) -> Double {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        let backToDate = dateFormatter.date(from: dobString)
        let now = Date()
        var finalAge = 0.0
        let calculatedAge = calculateAgeFrom(dob: backToDate ?? now)
        if calculatedAge < 2.0 {
            finalAge = 0.0
        } else {
         finalAge = calculatedAge
        }
        
        return finalAge
    }
    
    func calculateAgeFrom(dob: Date) -> Double {
        
        let dateOfBirth = dob
        // get today as a date object and compare
        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year,.month, .day], from: dateOfBirth, to: today)
        
        let ageYears = components.year
        let decimal =  Double(components.month!) / Double(12)
        let compositeNumb = Double(ageYears!) + decimal
        let  roundedNumb =    Double(compositeNumb).rounded(toPlaces: 1)
        return roundedNumb
    }


}


    
    /*
    func createNewDateInFirebase() {
        
        let boyFirstName = "Joe"
        let boyLastName = "Biden"
        let boyFullName = "BoyFullName"
        let girlFirstName = "Jill"
        let girlLastName = "Rogers"
        let girlFullName = "fuLLName"
        let datingStatus = "Active"
        let dateNumber = "4"
        let boysAge = "22"
        let girlAge = "22"
        let shadchanNotesNew = "Cute Couple"
        let nasiProgram = "Sefardim"
        let dateCreated = "\(Date())"
        let dateLastUpdate: Int = 0
        
        let newDate = NasiDate(boyFirstName: boyFirstName, boyLastName: boyLastName,boyFullName: boyFullName, boysAge: boysAge, dateNumber: dateNumber, datingStatus: datingStatus, girlFirstName: girlFirstName,girlLastName: girlLastName,girlFullName: girlFullName, girlAge: girlAge, shadchanNotes: shadchanNotes, dateCreated: dateCreated, dateLastUpdate: dateLastUpdate, nasiProgram: nasiProgram)
        
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let dateNodeRef = Database.database().reference().child("NasiDatesList").child(uid)
        
        let ref = dateNodeRef.childByAutoId()
        //let groceryItemRef = self.ref.child(text.lowercased())
        ref.setValue(newDate.toAnyObject())
    }
    */
    
    
    
    
    

