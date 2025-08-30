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
    var lastName: String { get set }
    var firstName: String { get set }
    var ageString: String { get set}
    var dateOfBirthString: String { get set }
    var key: String { get set }
    
}
extension Girl where Self: Comparable {
    var lastName: String {
        return "unknown"
    }
    var firstName: String {
        return "unknown"
    }
    var ageString: String {
        return "unknown"
    }
    var dateOfBirthString: String {
        return "unknown"
    }
    var key: String {
        return "unknown"
    }
    
}

class NasiGirl: NSObject, Girl, Comparable {
   
    var  ref: DatabaseReference?
    var  key: String = ""
    
    var dateOfBirthString: String = ""
    var ageString: String = ""
    
    var dateOfBirth = ""
    var age: Double = 0.0
    
    var firstName: String = ""
    var lastName: String = ""
    
    
   
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
    var firstNameOfGirl = ""
    var firstNameOfPersonToContactToReddShidduch = ""
    var fullhebrewNameOfGirlAndMothersHebrewName = ""
    var girlsCellNumber = ""
    var girlsEmailAddress = ""
    var heightInFeet  = ""
    var heightInInches = ""
    var imageDownloadURLString = ""
    var lastNameOfGirl = ""
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
    
    
    // when getting data from Firebase we convert the FB snapshot
    // dictionary into a swift object
    //
    init(snapshot: DataSnapshot) {
    //let value = snapshot.value as! [String: AnyObject]
        guard  let value = snapshot.value! as? [String: String] else { return }
        
        let lastNameOfGirl = value["lastNameOfGirl"] ?? ""
        
        let briefDescriptionOfWhatGirlIsLike = value["briefDescriptionOfWhatGirlIsLike"] ?? ""
        let briefDescriptionOfWhatGirlIsLookingFor = value["briefDescriptionOfWhatGirlIsLookingFor"] ?? ""
        let briefDescriptionOfWhatGirlIsDoing = value["briefDescriptionOfWhatGirlIsDoing"] ?? ""
        
        let titleOfPersonToReddShidduch = value["titleOfPersonToContactToReddShidduch"] ?? ""
        let titleOfAContactWhoKnowsGirl = value["titleOfAContactWhoKnowsGirl"] ?? ""
        let category = value["category"] ?? ""
        let cellNumberOfContactWhoKNowsGirl = value["cellNumberOfContactWhoKNowsGirl"] ?? ""
        
        let cellNumberOfContactToReddShidduch = value["cellNumberOfContactToReddShidduch"] ?? ""
        let cityOfResidence = value["cityOfResidence"] ?? ""
       
        var ageAsString: String = ""
        var age: Double = 0.0
        let dateOfBirth = value["dateOfBirth"] ?? "Empty"
       
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
        let documentDownloadURLString = value["documentDownloadURLString"] ?? ""
        let emailOfContactToReddShidduch = value["emailOfContactToReddShidduch"] ?? ""
        let emailOfContactWhoKnowsGirl = value["emailOfContactWhoKnowsGirl"] ?? ""
        let firstNameOfGirl = value["firstNameOfGirl"] ?? ""
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
    
    static func == (lhs: NasiGirl, rhs: NasiGirl)
    -> Bool {
        return lhs.lastName == rhs.lastName
        
    }
        static func < (lhs: NasiGirl, rhs: NasiGirl) ->
        Bool {
            return lhs.lastName < rhs.lastName
        }
    
    
    
    
    // when adding a girl to a firebase list
    // we start with a swift object that converts
    // to a dictionary
    init(name: String, key: String = "") {
       self.ref = nil
       self.key = key
       
    }
}
        
/*
        func toDate(formaterStyle:String) -> Date {
                   
                   let dateFormater = DateFormatter.init()
                   
                   dateFormater.timeZone = Calendar.current.timeZone
                   
                   dateFormater.locale  = Calendar.current.locale
                   
                   dateFormater.dateFormat = formaterStyle
                   
                   return dateFormater.date(from: self)!
               }
        
    */
        
        
      
/*
        // Just throw at it without any format.
        var date: Date? = Date.FromString("02-14-2019 17:05:05")
        Pretty enjoyable, it even recognizes things like "Tomorrow at 5".

        XCTAssertEqual(Date.FromString("2019-02-14"),                    Date.FromCalendar(2019, 2, 14))
        XCTAssertEqual(Date.FromString("2019.02.14"),                    Date.FromCalendar(2019, 2, 14))
        XCTAssertEqual(Date.FromString("2019/02/14"),                    Date.FromCalendar(2019, 2, 14))
        XCTAssertEqual(Date.FromString("2019 Feb 14"),                   Date.FromCalendar(2019, 2, 14))
        XCTAssertEqual(Date.FromString("2019 Feb 14th"),                 Date.FromCalendar(2019, 2, 14))
        XCTAssertEqual(Date.FromString("20190214"),                      Date.FromCalendar(2019, 2, 14))
        XCTAssertEqual(Date.FromString("02-14-2019"),                    Date.FromCalendar(2019, 2, 14))
        XCTAssertEqual(Date.FromString("02.14.2019 5:00 PM"),            Date.FromCalendar(2019, 2, 14, 17))
        XCTAssertEqual(Date.FromString("02/14/2019 17:00"),              Date.FromCalendar(2019, 2, 14, 17))
        XCTAssertEqual(Date.FromString("14 February 2019 at 5 hour"),    Date.FromCalendar(2019, 2, 14, 17))
        XCTAssertEqual(Date.FromString("02-14-2019 17:05:05"),           Date.FromCalendar(2019, 2, 14, 17, 05, 05))
        XCTAssertEqual(Date.FromString("17:05, 14 February 2019 (UTC)"), Date.FromCalendar(2019, 2, 14, 17, 05))
        XCTAssertEqual(Date.FromString("02-14-2019 17:05:05 GMT"),       Date.FromCalendar(2019, 2, 14, 17, 05, 05))
        XCTAssertEqual(Date.FromString("02-13-2019 Tomorrow"),           Date.FromCalendar(2019, 2, 14))
        XCTAssertEqual(Date.FromString("2019 Feb 14th Tomorrow at 5"),   Date.FromCalendar(2019, 2, 14, 17))
        Goes like:
*/
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
        
        
            
/*
briefDescriptionOfWhatGirlIsDoing:
"Tova Schwartz got a masters degree in data scie..."
briefDescriptionOfWhatGirlIsLike:
"Tova is frum, smart, fun, family oriented, has ..."
briefDescriptionOfWhatGirlIsLookingFor:
"Tova is looking for someone who learns in the b..."
category:
"FTL+PTL"
cellNumberOfContactToReddShidduch:
"8444459584"
cellNumberOfContactWhoKNowsGirl:
"3233850450"
cityOfResidence:
"Queens"
dateCreated:
"2021-11-09T14:37:35.185Z"
dateOfBirth:
"8/18/1997"
documentDownloadURLString:
"https://firebasestorage.googleapis.com/v0/b/nas..."
emailOfContactToReddShidduch:
"ramona.schwartz@touro.edu"
emailOfContactWhoKnowsGirl:
"Adenadyckman@outlook.com"
firstNameOfAContactWhoKnowsGirl:
"Adena"
firstNameOfGirl:
"Tova"
firstNameOfPersonToContactToReddShidduch:
"Ramona"
girlFamilyBackground:
"American, Yeshivish, Heimish"
girlFamilySituation:
"Lost her father 2005"
girlsCellNumber:
"(718) 310-7240"
hebrewNameOfGirl:
"N/A"
heightInFeet:
"5"
heightInInches:
"2"
imageDownloadURLString:
"https://firebasestorage.googleapis.com/v0/b/nas..."
koveahIttim:
"N/A"
lastNameOfAContactWhoKnowsGirl:
"Dyckman"
lastNameOfGirl:
"Schwartz"
lastNameOfPersonToContactToReddShidduch:
"Schwartz"
livingInIsrael:
"N/A"
mailOfContactToReddShidduch:
"N/A"
middleNameOfGirl:
"Gittel"
nameSheIsCalledOrKnownBy:
"Tova"
plan:
"Learning with some kind of a plan"
proTrack:
"N/A"
professionalTrack:
"does not need professional track"
relationshipOfReddShidduchContactToGirl:
"Mother"
relationshipOfThisContactToGirl:
"Daughters friend"
seminaryName:
"Michlala"
stateOfResidence:
"NY"
titleOfAContactWhoKnowsGirl:
"Mrs"
titleOfPersonToContactToReddShidduch:
"Mrs."
yearsOfLearning:
"1-3"

   */
        
        
        
            
        
        
        
            
            
         
        
        
        
        
        
        
        
       
    

