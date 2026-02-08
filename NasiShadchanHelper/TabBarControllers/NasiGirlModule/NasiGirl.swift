//
//  NasiGirl.swift
//  NasiShadchanHelper
//
//  Created by username on 12/17/20.
//  Copyright © 2020 user. All rights reserved.
//


import Foundation
import Firebase

protocol Girl {
    var firstName: String { get }
    var lastName: String { get }
    var ageString: String { get }
    var dateOfBirthString: String { get }
    var key: String { get }
}


    
final class NasiGirl: NSObject, Girl, Comparable {
    // original storage
    var firstNameOfGirl = ""
    var lastNameOfGirl = ""
    var dateOfBirth = ""     // stored as String in your model
    var age: Double = 0.0
    var key = ""
    var ref: DatabaseReference?
    
    // protocol mapping
    var firstName: String { firstNameOfGirl }
    var lastName: String { lastNameOfGirl }
    var dateOfBirthString: String { dateOfBirth }
    var ageString: String { age == 0 ? "" : String(age) }
    
    static func < (lhs: NasiGirl, rhs: NasiGirl) -> Bool {
        (lhs.lastName.lowercased(), lhs.firstName.lowercased(), lhs.key)
        < (rhs.lastName.lowercased(), rhs.firstName.lowercased(), rhs.key)
    }
    static func == (lhs: NasiGirl, rhs: NasiGirl) -> Bool { lhs.key == rhs.key }
    
    
    
    var  researchListKey: String = ""
    var  researchListRef: String = ""
    var  sentListKey: String = ""
    var  sentListRef: String = ""
    var  briefDescriptionOfWhatGirlIsLike = ""
    var  briefDescriptionOfWhatGirlIsLookingFor = ""
    
    
    var briefDescriptionOfWhatGirlIsDoing = ""
    var titleOfPersonToReddShidduch = ""
    var titleOfAContactWhoKnowsGirl = ""
    
    
    var category = ""
    var cellNumberOfContactToReddShidduch = ""
    var cityOfResidence = ""
    
    var documentDownloadURLString = ""
    var emailOfContactToReddShidduch = ""
    var emailOfContactWhoKnowsGirl = ""
    
    var firstNameOfPersonToContactToReddShidduch = ""
    var fullhebrewNameOfGirlAndMothersHebrewName = ""
    var girlsCellNumber = ""
    var girlsEmailAddress = ""
    var heightInFeet  = ""
    var heightInInches = ""
    var imageDownloadURLString = ""
    
    var lastNameOfPersonToContactToReddShidduch = ""
    var middleNameOfGirl = ""
    var nameSheIsCalledOrKnownBy = ""
    var plan = ""
    var relationshipOfThisContactToGirl = ""
    var relationshipOfReddShidduchContactToGirl = ""
    var seminaryName = ""
    var stateOfResidence = ""
    var yearsOfLearning = ""
    var zipCode = ""
    var cellNumberOfContactWhoKNowsGirl = ""
    var firstNameOfAContactWhoKnowsGirl = ""
    var girlFamilyBackground = ""
    var koveahIttim = ""
    var lastNameOfAContactWhoKnowsGirl = ""
    var livingInIsrael = ""
    var professionalTrack = ""
    var girlFamilySituation = ""
    
    //var timestamp: NSNumber?
    
    
    
    init(snapshot: DataSnapshot) {
        //let value = snapshot.value as! [String: AnyObject]
        guard  let value = snapshot.value! as? [String: String] else { return }
        
        let lastNameOfGirl = value["lastNameOfGirl"] ?? ""
        let firstNameOfGirl = value["firstNameOfGirl"] ?? ""
        let dateOfBirth = value["dateOfBirth"] ?? "Empty"
        
        var ageAsString: String = ""
        var age: Double = 0.0
        
        
        // because we are getting a "testID 88" in the list
        if dateOfBirth != "Empty" {
            var date: Date? = Date.FromString(dateOfBirth)
            if let birthDate = date {
                age = calculateAgeFrom(dob: birthDate)
                ageAsString = "\(age)"
            } else {
                ageAsString = "0.0"
            }
        }
        
        let briefDescriptionOfWhatGirlIsLike = value["briefDescriptionOfWhatGirlIsLike"] ?? ""
        let briefDescriptionOfWhatGirlIsLookingFor = value["briefDescriptionOfWhatGirlIsLookingFor"] ?? ""
        let briefDescriptionOfWhatGirlIsDoing = value["briefDescriptionOfWhatGirlIsDoing"] ?? ""
        
        let titleOfPersonToReddShidduch = value["titleOfPersonToContactToReddShidduch"] ?? ""
        let titleOfAContactWhoKnowsGirl = value["titleOfAContactWhoKnowsGirl"] ?? ""
        let category = value["category"] ?? ""
        let cellNumberOfContactWhoKNowsGirl = value["cellNumberOfContactWhoKNowsGirl"] ?? ""
        
        let cellNumberOfContactToReddShidduch = value["cellNumberOfContactToReddShidduch"] ?? ""
        let cityOfResidence = value["cityOfResidence"] ?? ""
        
        
        let documentDownloadURLString = value["documentDownloadURLString"] ?? ""
        let emailOfContactToReddShidduch = value["emailOfContactToReddShidduch"] ?? ""
        let emailOfContactWhoKnowsGirl = value["emailOfContactWhoKnowsGirl"] ?? ""
        
        let firstNameOfPersonToContactToReddShidduch = value["firstNameOfPersonToContactToReddShidduch"] ?? ""
        let firstNameOfAContactWhoKnowsGirl = value["firstNameOfAContactWhoKnowsGirl"] ?? ""
        _ = value["fullhebrewNameOfGirlAndMothersHebrewName"] ?? ""
        let girlsCellNumber = value["girlsCellNumber"] ?? ""
        let girlsEmailAddress = value["girlsEmailAddress"] ?? ""
        let girlFamilyBackground = value["girlFamilyBackground"] ?? ""
        let girlFamilySituation = value["girlFamilySituation"]
        ?? ""
        
        
        let heightInFeet = value["heightInFeet"] ?? ""
        let heightInInches = value["heightInInches"] ?? ""
        
        let imageDownloadURLString = value["imageDownloadURLString"] ?? ""
        
        let koveahIttim = value["koveahIttim"] ?? ""
        
        let lastNameOfPersonToContactToReddShidduch = value["lastNameOfPersonToContactToReddShidduch"] ?? ""
        
        let lastNameOfAContactWhoKnowsGirl = value["lastNameOfAContactWhoKnowsGirl"] ?? ""
        
        let livingInIsrael = value["livingInIsrael"] ?? ""
        let middleNameOfGirl = value["middleNameOfGirl"] ?? ""
        let nameSheIsCalledOrKnownBy = value["nameSheIsCalledOrKnownBy"] ?? ""
        
        let plan = value["plan"] ?? ""
        let professionalTrack = value["professionalTrack"] ?? ""
        
        let relationshipOfThisContactToGirl = value["relationshipOfThisContactToGirl"] ?? ""
        
        let relationshipOfReddShidduchContactToGirl = value["relationshipOfReddShidduchContactToGirl"] ?? ""
        
        let seminaryName = value["seminaryName"] ?? ""
        
        let stateOfResidence = value["stateOfResidence"] ?? ""
        
        let yearsOfLearning = value["yearsOfLearning"] ?? ""
        let zipCode = value["zipCode"] ?? ""
        
        
        
        // FB snapshot has a ref and key property
        self.ref = snapshot.ref
        self.key = snapshot.key
        
        self.briefDescriptionOfWhatGirlIsLike = briefDescriptionOfWhatGirlIsLike
        self.briefDescriptionOfWhatGirlIsLookingFor = briefDescriptionOfWhatGirlIsLookingFor
        
        self.briefDescriptionOfWhatGirlIsDoing = briefDescriptionOfWhatGirlIsDoing
        
        
        self.titleOfPersonToReddShidduch = titleOfPersonToReddShidduch
        self.titleOfAContactWhoKnowsGirl = titleOfAContactWhoKnowsGirl
        
        self.category = category
        self.cellNumberOfContactToReddShidduch = cellNumberOfContactToReddShidduch
        self.cellNumberOfContactWhoKNowsGirl = cellNumberOfContactWhoKNowsGirl
        
        self.cityOfResidence = cityOfResidence
        self.dateOfBirth = dateOfBirth
        self.age = age
        
        self.documentDownloadURLString = documentDownloadURLString
        self.emailOfContactToReddShidduch = emailOfContactToReddShidduch
        self.emailOfContactWhoKnowsGirl = emailOfContactWhoKnowsGirl
        
        self.firstNameOfGirl = firstNameOfGirl
        self.firstNameOfPersonToContactToReddShidduch = firstNameOfPersonToContactToReddShidduch
        //self.fullhebrewNameOfGirlAndMothersHebrewName = fullhebrewNameOfGirlAndMothersHebrewName
        
        self.girlsCellNumber = girlsCellNumber
        self.girlsEmailAddress = girlsEmailAddress
        
        self.heightInFeet  = heightInFeet
        self.heightInInches = heightInInches
        
        self.imageDownloadURLString = imageDownloadURLString
        self.lastNameOfGirl = lastNameOfGirl
        self.lastNameOfPersonToContactToReddShidduch = lastNameOfPersonToContactToReddShidduch
        
        
        
        self.middleNameOfGirl = middleNameOfGirl
        self.nameSheIsCalledOrKnownBy = nameSheIsCalledOrKnownBy
        self.plan = plan
        self.relationshipOfThisContactToGirl = relationshipOfThisContactToGirl
        self.relationshipOfReddShidduchContactToGirl = relationshipOfReddShidduchContactToGirl
        self.seminaryName = seminaryName
        self.stateOfResidence = stateOfResidence
        self.yearsOfLearning = yearsOfLearning
        self.zipCode = zipCode
        
        self.firstNameOfAContactWhoKnowsGirl = firstNameOfAContactWhoKnowsGirl
        self.girlFamilyBackground = girlFamilyBackground
        self.koveahIttim = koveahIttim
        self.lastNameOfAContactWhoKnowsGirl = lastNameOfAContactWhoKnowsGirl
        self.livingInIsrael = livingInIsrael
        self.professionalTrack = professionalTrack
        self.girlFamilySituation = girlFamilySituation
    }
}
    
    
    
    
    
    
        

        
        
        extension Date
        {


            public static func FromString(_ dateString: String) -> Date?
            {
                // Date detector.
                let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)

                // Enumerate matches.
                var matchedDate: Date?
                var matchedTimeZone: TimeZone?
                detector.enumerateMatches(
                    in: dateString,
                    options: [],
                    range: NSRange(location: 0, length: dateString.utf16.count),
                    using:
                    {
                        (eachResult, _, _) in

                        // Lookup matches.
                        matchedDate = eachResult?.date
                        matchedTimeZone = eachResult?.timeZone

                        // Convert to GMT (!) if no timezone detected.
                        if matchedTimeZone == nil, let detectedDate = matchedDate
                        { matchedDate = Calendar.current.date(byAdding: .second, value: TimeZone.current.secondsFromGMT(), to: detectedDate)! }
                })

                // Result.
                return matchedDate
            }
        }
        
        
        
            
        
        
        
            
            
         
        
        
        
        
        
        
        
       
    

