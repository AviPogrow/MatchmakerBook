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
    
    // original properties
    var girlLastName = ""
    var girlFirstName = ""
    var dobIntervalString = ""
    var computedAgeString: String = ""
    
   
    // protocol mapping
    var firstName: String { girlFirstName }
    var lastName: String { girlLastName }
    var dateOfBirthString: String { dobIntervalString }
    var ageString: String { computedAgeString }
    
    // Firebase storage key (keep this as-is)
    var categories: [String] = []
    // Domain name (use this everywhere in app/UI)
    var lifePlans: [String] {
        get { categories }
        set { categories = newValue }
    }
    
    var  ref: DatabaseReference?
    var  key: String = ""
    var status = "available"
  
    var city = ""
    var girlHeight = ""
    var girlCell = ""
    var sendResumeEmail = ""
    var sendResumeText = ""
   
    var dateCreated = ""
    var  dateLastUpdate: Int   = 0
    var datingHistory = ""
    var shadchanNotesNew = ""
    
    // media
    var notesImageURL = ""
    var resumeImageURL = ""
    var photoImageURL = ""
    
    init(snapshot: DataSnapshot) {
        super.init()
    
        guard let value = snapshot.value as? [String: Any] else { return }

        
        let girlLastName = value["girlLastName"] as? String
        let girlFirstName = value["girlFirstName"] as? String
        let girlCell = value["girlCell"] as? String
        let city = value["city"] as? String
        let girlHeight = value["girlHeight"] as? String
        
        let categories = value["categories"] as? [String]
        
        let dateCreated = value["dateCreated"] as? String
        let dateLastUpdate = value["dateLastUpdate"]  as? Int
        let dobIntervalString = value["dobIntervalString"] as? String
        
        let sendResumeEmail = value["sendResumeEmail"] as? String
        let sendResumeText = value["sendResumeText"] as? String
        
        
        let status = value["status"] as? String
        let datingHistory = value["datingHistory"] as? String
        let shadchanNotesNew = value["shadchanNotesNew"] as? String
    
        let notesImageURL = value["notesImageURL"] as? String
        let resumeImageURL = value["resumeImageURL"] as? String
        let photoImageURL = value["photoImageURL"] as? String
       
        // FB snapshot has a ref and key property
        self.ref = snapshot.ref
        self.key = snapshot.key
        
        self.girlFirstName = girlFirstName ?? ""
        self.girlLastName = girlLastName ?? ""
        self.city = city ?? ""
        self.girlCell = girlCell ?? ""
        self.girlHeight = girlHeight ?? ""
         
        
        self.dateCreated = dateCreated ?? ""
        self.dobIntervalString = dobIntervalString ?? ""
        self.dateLastUpdate = dateLastUpdate ?? 0
    
       
        self.sendResumeEmail = sendResumeEmail ?? ""
        self.sendResumeText = sendResumeText ?? ""
        self.categories = categories ?? [String]()
        self.status = status ?? "available"
        
        self.datingHistory = datingHistory ?? ""
        self.shadchanNotesNew = shadchanNotesNew ?? ""
        
        self.notesImageURL = notesImageURL ?? ""
        self.resumeImageURL = resumeImageURL ?? ""
        self.photoImageURL = photoImageURL ?? ""
        
        let age = calculateAgeFrom(dobString: self.dobIntervalString)
        self.computedAgeString = age > 0 ? "\(age)" : ""
    }
    
    // MARK: Initialize with data from user input
    init(girlCell: String,
         girlLastName: String,
         girlFirstName:String,
         city: String,
         dobIntervalString:String,
         dateCreated: String,
         dateLastUpdate: Int,
         girlHeight: String,
         sendResumeEmail: String,
         sendResumeText:String,
         lifePlans: [String],
         status: String,
         datingHistory: String,
         shadchanNotesNew: String,
         notesImageURL: String,
         resumeImageURL:String,
         photoImageURL: String,
         key: String = "") {
      
      self.girlCell = girlCell
      self.girlFirstName = girlFirstName
      self.girlLastName = girlLastName
      self.city = city
      self.dateCreated = dateCreated
      self.dobIntervalString = dobIntervalString
      self.dateLastUpdate = dateLastUpdate
        
     // self.dob = dob
      self.girlHeight = girlHeight
      self.sendResumeEmail = sendResumeEmail
      self.sendResumeText = sendResumeText
       self.categories = lifePlans
      self.status = status
        self.shadchanNotesNew = shadchanNotesNew
        self.datingHistory = datingHistory
        self.notesImageURL = notesImageURL
      self.resumeImageURL = resumeImageURL
      self.photoImageURL = photoImageURL
    }
    
    // MARK: Convert ShadchanGirl to AnyObject
    func toDictionary() -> [String: Any] {
        return [
        "girlCell": girlCell,
        "girlLastName": girlLastName,
        "girlFirstName": girlFirstName,
        "city": city,
        "girlHeight": girlHeight,
        "dateCreated": dateCreated,
        "dateLastUpdate": dateLastUpdate,
        "dobIntervalString": dobIntervalString,
        "sendResumeEmail": sendResumeEmail,
        "sendResumeText": sendResumeText,
        "categories": categories,
        "status": status,
        "datingHistory": datingHistory,
         "shadchanNotesNew": shadchanNotesNew,
        "notesImageURL": notesImageURL,
        "resumeImageURL": resumeImageURL,
        "photoImageURL": photoImageURL
      ]
    }
    
    static func == (lhs: ShadchanGirl, rhs: ShadchanGirl) -> Bool {
        lhs.key == rhs.key
    }

 
    
    func calculateAgeFrom(dobString: String) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "YY/MM/dd" // keep for now

        guard let backToDate = dateFormatter.date(from: dobString) else { return 0.0 }

        let calculatedAge = calculateAgeFrom(dob: backToDate)
        return calculatedAge < 2.0 ? 0.0 : calculatedAge
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




