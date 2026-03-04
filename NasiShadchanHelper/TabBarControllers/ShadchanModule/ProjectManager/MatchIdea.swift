//
//
//  MatchIdea.swift
//  NasiShadchanHelper
//
//  Created by test on 2/20/23.
//  Copyright © 2023 user. All rights reserved.
//

import Foundation
import Firebase

class MatchIdea: NSObject {
    
    var  ref: DatabaseReference?
    var  key: String = ""
    
    var boyID = ""
    var girlID = ""
    var boyFirstName = ""
    var boyLastName = ""
    var girlFirstName = ""
    var girlLastName = ""
    var girlImageDownloadString = ""
    var girlResumeDownloadString = ""
    var boySendResumeEmail = ""
    var boySendResumeText = ""
    var boyCell = ""
    var boyPhotoImageURL = ""
    
    // time stamp for each stage
    var timeStampForIdea = ""
    var timeStampForRedd = ""
    var timeStampForFirstDate = ""
    var timeStampForSecondDate = ""
    var timeStampForThirdDate = ""
    var timeStampForFourthDate = ""
    
    // date of dates
    var dateOfFirstDate = ""
    var dateOfSecondDate = ""
    var dateOfThirdDate = ""
    var dateOfFourthDate = ""
   
    var currentStage = "idea"
   
    // initialize from a firebase snapshot coming down int
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
        
        let currentStage = value["currentStage"] as? String
        
        
        // time stamp for each stage
        let  timeStampForIdea = value["timeStampForIdea"] as? String
        var timeStampForRedd = value["timeStampForRedd"] as? String
        var timeStampForFirstDate = value["timeStampForFirstDate"] as? String
        var timeStampForSecondDate = value["timeStampForSecondDate"] as? String
        var timeStampForThirdDate = value["timeStampForThirdDate"] as? String
        var timeStampForFourthDate = value["timeStampForFourthDate"] as? String
        
        // date of dates
        var dateOfFirstDate = value["dateOfFirstDate"] as? String
        var dateOfSecondDate = value["dateOfSecondDate"] as? String
        var dateOfThirdDate = value["dateOfThirdDate"] as? String
        var dateOfFourthDate = value["dateOfFourthDate"] as? String
        
        
        
        self.boyID = boyID ?? "noBoyID"
         self.girlID = girlID ?? "noGirlID"
        
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
        
        self.currentStage = currentStage ?? "no stage"
        
        // time stamp for each stage
        self.timeStampForIdea = timeStampForIdea ?? "No stamp for idea"
        self.timeStampForRedd = timeStampForRedd ?? "no stamp for redd"
        self.timeStampForFirstDate = timeStampForFirstDate ?? "no stamp for first date"
        self.timeStampForSecondDate = timeStampForSecondDate ?? "no stamp for second"
        self.timeStampForThirdDate = timeStampForThirdDate ?? "no stamp for third date"
        self.timeStampForFourthDate = timeStampForFourthDate ?? "no stamp for fourth date"
        
        // date of dates
        self.dateOfFirstDate = dateOfFirstDate ?? "no date for first date"
        self.dateOfSecondDate = dateOfSecondDate ?? "no date for second date"
        self.dateOfThirdDate = dateOfThirdDate ?? "no date for third date"
        self.dateOfFourthDate = dateOfFourthDate ?? "no date for fourth date"
       }
    
    // init the object to send up to firebase
    init(boyID: String, girlID: String,dateCreated: String, boyFirstName: String,boyLastName: String,girlFirstName: String, girlLastName:String,girlImageDownloadString: String,girlResumeDownlaodString: String,boySendResumeEmail: String, boySendResumeText: String,boyCell: String,boyPhotoImageURL: String, currentStage: String,timeStampForIdea: String,timeStampForRedd: String,timeStampForFirstDate: String, timeStampForSecondDate: String, timeStampForThirdDate: String, timeStampForFourthDate: String, dateOfFirstDate: String, dateOfSecondDate: String, dateOfThirdDate: String, dateOfFourthDate: String){
        
        self.boyID = boyID
        self.girlID = girlID
    
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
        self.currentStage = currentStage
        
        
        // time stamp for each stage
        self.timeStampForIdea = timeStampForIdea
        self.timeStampForRedd = timeStampForRedd
        self.timeStampForFirstDate = timeStampForFirstDate
        self.timeStampForSecondDate = timeStampForSecondDate
        self.timeStampForThirdDate = timeStampForThirdDate
        self.timeStampForFourthDate = timeStampForFourthDate
        
        // date of dates
        self.dateOfFirstDate = dateOfFirstDate
        self.dateOfSecondDate = dateOfSecondDate
        self.dateOfThirdDate = dateOfThirdDate
        self.dateOfFourthDate = dateOfFourthDate
       
    }
    
   
    // MARK: Convert GroceryItem to AnyObject
    func toAnyObject() -> Any {
      return [
        "dateOfFirstDate":dateOfFirstDate,
        "dateOfSecondDate":dateOfSecondDate,
        "dateOfThirdDate":dateOfThirdDate,
        "dateOfFourthDate":dateOfFourthDate,
        "timeStampForIdea":timeStampForIdea,
        "timeStampForRedd":timeStampForRedd,
        "timeStampForFirstDate":timeStampForFirstDate,
        "timeStampForSecondDate":timeStampForSecondDate,
        "timeStampForThirdDate":timeStampForThirdDate,
        "timeStampForFourthDate":timeStampForFourthDate,
        "boyID": boyID,
        "girlID": girlID,
        "boyFirstName":boyFirstName,
        "boyLastName": boyLastName,
        "girlFirstName":girlFirstName,
        "girlLastName":girlLastName,
        "girlImageDownloadString":girlImageDownloadString,
        "girlResumeDownloadString":girlResumeDownloadString,
        "boySendResumeEmail":boySendResumeEmail,
        "boySendResumeText":boySendResumeText,
        "boyCell":boyCell,
        "boyPhotoImageURL":boyPhotoImageURL,
        "currentStage": currentStage
        ]
    }
}
