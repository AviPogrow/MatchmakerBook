//
//  ShadchanGirl.swift
//  NasiShadchanHelper
//
//  Created by test on 11/15/22.
//  Copyright © 2022 user. All rights reserved.
//


import Foundation
import Firebase

class ShadchanGirl: NSObject, Girl {
    var dateOfBirthString: String = ""
    
    var ageString: String = ""
   
    var ageEntered: Int = 0
    var dobIntervalString = ""
    var calculatedAge = ""
    
    var firstName: String = ""
    var lastName: String = ""
    
    var  ref: DatabaseReference?
    var  key: String = ""
    
    var girlLastName = ""
    var girlFirstName = ""
    var city = ""
    
    
    var girlHeight = ""
    
    var girlCell = ""
    var sendResumeEmail = ""
    var sendResumeText = ""
    
    var categories: [String] = []
    var status = "available"
    
    var dateCreated = ""
    var  dateLastUpdate: Int   = 0
    
    var datingHistory = ""
    var shadchanNotesNew = ""
    var shadchanNotes = ""
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
        
      
        let girlCell = value["girlCell"] as? String
        let girlLastName = value["girlLastName"] as? String
        let girlFirstName = value["girlFirstName"] as? String
        let city = value["city"] as? String
        var girlHeight = value["girlHeight"] as? String
        
        let ageEntered = value["ageEntered"] as? Int
        let dateCreated = value["dateCreated"] as? String
        let dateLastUpdate = value["dateLastUpdate"]  as? Int
        //let dob = value["dob"] as? Date
        let dobIntervalString = value["dobIntervalString"] as? String
        let calculatedAge = value["calculatedAge"] as? String
        
        
        let sendResumeEmail = value["sendResumeEmail"] as? String
        let sendResumeText = value["sendResumeText"] as? String
        let categories = value["categories"] as? [String]
        
        let status = value["status"] as? String
        let datingHistory = value["datingHistory"] as? String
        var shadchanNotesNew = value["shadchanNotesNew"] as? String
        let shadchanNotes = value["shadchanNotes"] as? String
        let notesImageURL = value["notesImageURL"] as? String
        let resumeImageURL = value["resumeImageURL"] as? String
        let photoImageURL = value["photoImageURL"] as? String
       
        
        self.girlFirstName = girlFirstName ?? ""
        self.girlLastName = girlLastName ?? ""
        self.city = city ?? ""
        self.girlCell = girlCell ?? ""
        self.girlHeight = girlHeight ?? ""
         
        self.ageEntered = ageEntered ?? 0
        self.dateCreated = dateCreated ?? ""
        self.dobIntervalString = dobIntervalString ?? ""
        
        
        self.dateLastUpdate = dateLastUpdate ?? 0
       // self.dob = dob
        self.calculatedAge = calculatedAge ?? ""
        self.sendResumeEmail = sendResumeEmail ?? ""
        self.sendResumeText = sendResumeText ?? ""
        self.categories = categories ?? [String]()
        self.status = status ?? "available"
        
        self.datingHistory = datingHistory ?? ""
        self.shadchanNotesNew = shadchanNotesNew ?? ""
        self.shadchanNotes = shadchanNotes ?? ""
        self.notesImageURL = notesImageURL ?? ""
        self.resumeImageURL = resumeImageURL ?? ""
        self.photoImageURL = photoImageURL ?? ""
        
        self.dobIntervalString = dobIntervalString ?? ""
        let nowString = "\(Date())"
        let age = calculateAgeFrom(dobString: dobIntervalString ?? nowString)
        self.calculatedAge = "\(age)"
    }
    
    // MARK: Initialize with data from user input
    init(girlCell: String, girlLastName: String,girlFirstName:String,city: String,calculatedAge: String, ageEntered:Int, dobIntervalString:String,  dateCreated: String,dateLastUpdate: Int, girlHeight: String, sendResumeEmail: String,sendResumeText:String,categories: [String],status: String,datingHistory: String, shadchanNotesNew: String,shadchanNotes: String, notesImageURL: String,resumeImageURL:String, photoImageURL: String, key: String = "") {
        
        
      self.ref = nil
      self.key = key
      
      self.girlCell = girlCell
      self.girlFirstName = girlFirstName
      self.girlLastName = girlLastName
        self.city = city
    
        self.ageEntered = ageEntered
      self.dateCreated = dateCreated
      self.dobIntervalString = dobIntervalString
        self.dateLastUpdate = dateLastUpdate
        
     // self.dob = dob
      self.calculatedAge = calculatedAge
      self.girlHeight = girlHeight
    
    
      self.sendResumeEmail = sendResumeEmail
      self.sendResumeText = sendResumeText
    
      self.categories = categories
        self.status = status
        self.shadchanNotesNew = shadchanNotesNew
        self.datingHistory = datingHistory
        self.shadchanNotes = shadchanNotes
      self.notesImageURL = notesImageURL
      self.resumeImageURL = resumeImageURL
      self.photoImageURL = photoImageURL
        
        
        
    }
    
    static func == (lhs: ShadchanGirl, rhs: ShadchanGirl)
    -> Bool {
        return lhs.lastName == rhs.lastName
        
    }
        static func < (lhs: ShadchanGirl, rhs: ShadchanGirl) ->
        Bool {
            return lhs.lastName < rhs.lastName
        }
    
    // MARK: Convert GroceryItem to AnyObject
    func toAnyObject() -> Any {
      return [
        "girlCell": girlCell,
        "girlLastName": girlLastName,
        "girlFirstName": girlFirstName,
        "city": city,
        "girlHeight": girlHeight,
        "ageEntered": ageEntered,
        "dateCreated": dateCreated,
        "dateLastUpdate": dateLastUpdate,
        "dobIntervalString": dobIntervalString,
        "calculatedAge": calculatedAge,
        "sendResumeEmail": sendResumeEmail,
        "sendResumeText": sendResumeText,
        "categories": categories,
        "status": status,
        "datingHistory": datingHistory,
         "shadchanNotesNew": shadchanNotesNew,
        "shadchanNotes": shadchanNotes,
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

    
    
    
    
    
    
    func addShadchanGirl() {
        
        let newerGirl = ShadchanGirl(girlCell: "", girlLastName: "", girlFirstName: "", city: "", calculatedAge: "",ageEntered: 0, dobIntervalString: "", dateCreated: "", dateLastUpdate: 66, girlHeight: "", sendResumeEmail: "", sendResumeText: "", categories: ["",""], status: "", datingHistory: "", shadchanNotesNew: "", shadchanNotes: "", notesImageURL: "", resumeImageURL: "", photoImageURL: "")
        /*
        let newGirl = ShadchanGirl(girlCell: "2223334545", girlLastName: "Pogrow", girlFirstName: "Shayna", city: "CITY",calculatedAge: "33", dobIntervalString: "", dateCreated: "7/7/21", dateLastUpdate: 66, girlHeight: "5'3", sendResumeEmail: "rpogrow@gmail.com", sendResumeText: "3234445656", categories: ["Yeshivish","Chasidish"], status: "", shadchanNotes: "great guy",shadchanNotesNew: "",datingHistory: "",notesImageURL: "", resumeImageURL: "", photoImageURL: "")
        */
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let shadchanGirlNodeRef = Database.database().reference().child("ShadchanGirlsList").child(uid)
        
        let ref = shadchanGirlNodeRef.childByAutoId()
        
        ref.setValue(newerGirl.toAnyObject())
        
    }
  
}


struct ShadchanGirlGroup  {
    
    var imageString: String!
    var titleString: String!
    var arrayOfShadchanGirls: [ShadchanGirl]!
    
    init(imageString: String!, titleString: String!, arrayOfShadchanGirls: [ShadchanGirl]!) {
        self.imageString = imageString
        self.titleString = titleString
        self.arrayOfShadchanGirls = arrayOfShadchanGirls
    }

}








