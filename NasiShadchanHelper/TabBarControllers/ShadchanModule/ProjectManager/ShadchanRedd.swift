//
//  ShadchanRedd.swift
//  NasiShadchanHelper
//
//  Created by test on 2/21/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import Firebase

class ShadchanRedd: NSObject {
    
    var  ref: DatabaseReference?
    var  key: String = ""

    var matchIdeaID: String! = ""
    var dateSavedToRedd: String! =  ""
    var boyID: String! = ""
    var girlID: String! = ""
    var dateCreated: String! = ""
    var boyFirstName: String! = ""
    var boyLastName: String! = ""
    var girlFirstName: String! = ""
    var girlLastName: String! = ""
    var girlImageDownloadString: String! = ""
    var girlResumeDownloadString: String! = ""
    var boySendResumeEmail: String! = ""
    var boySendResumeText: String! = ""
    var boyCell: String! = ""
    var boyPhotoImageURL: String! = ""
    
    // initialize from a firebase snapshot coming down into app
    init(snapshot: DataSnapshot) {
    //let value = snapshot.value as! [String: AnyObject]
    guard  let value = snapshot.value! as? [String: AnyObject] else { return }
        
        // FB snapshot has a ref and key property
        self.ref = snapshot.ref
        self.key = snapshot.key
        
        
            let boyID = value["boyID"]  as? String
            let girlID = value["girlID"] as? String
            let boyFirstName = value["boyFirstName"]  as? String
            let boyLastName = value["boyLastName"] as? String
            let girlFirstName = value["girlFirstName"] as? String
            let girlLastName = value["girlLastName"] as? String
            let girlImageDownloadString = value["girlImageDownloadString"] as? String
            let girlResumeDownloadString = value["girlResumeDownloadString"] as? String
            let boySendResumeEmail = value["boySendResumeEmail"]  as? String
            let boySendResumeText = value["boySendResumeText"]  as? String
            let boyCell = value["boyCell"] as? String
            let boyPhotoImageURL = value["boyPhotoImageURL"] as? String
            let dateCreated = value["dateCreated"] as? String
            
        self.boyID = boyID ?? "noBoyID"
         self.girlID = girlID ?? "noGirlID"
         self.dateCreated = dateCreated ?? "dateCreatedBlank"
        self.boyFirstName = boyFirstName ?? "no boys First Name"
        self.boyLastName = boyLastName ?? "no boys First Name"
        self.girlFirstName = girlFirstName ?? "no girl 1st name"
        self.girlLastName = girlLastName ?? "no girl last Name"
        self.girlImageDownloadString = girlImageDownloadString ?? "no download Image String"
        self.girlResumeDownloadString = girlResumeDownloadString ?? "no resume string"
        self.boySendResumeEmail = boySendResumeEmail ?? "no resume email for boy"
        self.boySendResumeText = boySendResumeText ?? "no resume text for boy"
        self.boyCell = boyCell ?? "no cell for boy"
        self.boyPhotoImageURL = boyPhotoImageURL ?? "no image url for boy"
     }
    
    // init the object to send up to firebase
    init(boyID: String, girlID: String,dateCreated: String, boyFirstName: String,boyLastName: String,girlFirstName: String, girlLastName:String,girlImageDownloadString: String,girlResumeDownlaodString: String,boySendResumeEmail: String, boySendResumeText: String,boyCell: String,boyPhotoImageURL: String){
        
        self.boyID = boyID
        self.girlID = girlID
        self.dateCreated = dateCreated
        self.boyFirstName = boyFirstName
        self.boyLastName = boyLastName
        self.girlFirstName = girlFirstName
        self.girlLastName = girlLastName
        self.girlImageDownloadString = girlImageDownloadString
        self.girlResumeDownloadString = girlResumeDownlaodString
        self.boySendResumeEmail = boySendResumeEmail
        self.boySendResumeText = boySendResumeText
        self.boyCell = boyCell
        self.boyPhotoImageURL = boyPhotoImageURL
    }
    
    // MARK: Convert GroceryItem to AnyObject
    func toAnyObject() -> Any {
      return [
        "boyID": boyID,
        "girlID": girlID,
        "dateCreated": dateCreated,
        "boyFirstName":boyFirstName,
        "boyLastName": boyLastName,
        "girlFirstName":girlFirstName,
        "girlLastName":girlLastName,
        "girlImageDownloadString":girlImageDownloadString,
        "girlResumeDownloadString":girlResumeDownloadString,
        "boySendResumeEmail":boySendResumeEmail,
        "boySendResumeText":boySendResumeText,
        "boyCell":boyCell,
        "boyPhotoImageURL":boyPhotoImageURL
        ]
    }
    
}
