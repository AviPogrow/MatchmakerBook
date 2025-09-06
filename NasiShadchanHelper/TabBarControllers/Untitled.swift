//
//  Untitled.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 3/20/25.
//  Copyright © 2025 user. All rights reserved.
//

// a model to describe one dating relationship
// between one boy and one girl
struct DatingRelationship {
    //github auth token
    //***REMOVED***
    var boyId: String
    var boyName: String
    var boyCellNumber:String
    
    var girlId: String
    var girlName: String
    var girlCellNumber:String
   
    
    init(boyId: String, boyName: String, boyCellNumber: String, girlId: String, girlName: String, girlCellNumber: String) {
        self.boyId = boyId
        self.boyName = boyName
        self.boyCellNumber = boyCellNumber
        self.girlId = girlId
        self.girlName = girlName
        self.girlCellNumber = girlCellNumber
    
    }
    
    /*
    init?(dictionary: [String: Any]) {
        guard let boysName = dictionary["boyName"] as? String,
        let girlName = dictionary["girlName"] as? String,
        let boyCellNumber = dictionary["boyCellNumber"] as? String,
        let boyId = dictionary["boyId"] as? String
        else {
            return nil
        }
        self.boyId = boyId
        self.boyName = boysName
        self.girlName = girlName
        self.boyCellNumber = boyCellNumber
    }
     */
    func toDictionary() -> [String: Any] {
        return [
            "boyId": boyId,
            "boyName": boyName,
            "girlName": girlName,
            "boyCellNumber":boyCellNumber
        ]
    }
}

// a model to hold a list of "dating relationships"
 // where you may have one boy dating more than one girl
struct DatingHistory {
    var boyId: String
    var boysName: String
    var boysCellNumber: String
    
    var girlId: String
    var girlsName: String
    var girlsCellNumber: String
    
    var dates:[DatingRelationship]
    
    init(boyId: String, boysName: String, boysCellNumber: String, girlId: String, girlsName: String, girlsCellNumber: String, dates: [DatingRelationship]) {
        self.boyId = boyId
        self.boysName = boysName
        self.boysCellNumber = boysCellNumber
        self.girlId = girlId
        self.girlsName = girlsName
        self.girlsCellNumber = girlsCellNumber
        self.dates = dates
    }
        
    }
    /*
    // convert from dictionary
    init?(dictionary: [String: Any]) {
        guard let boyId = dictionary["boyId"] as? String,
              let boysName = dictionary["boysName"] as? String,
              let boysCellNumber = dictionary["boysCellNumber"] as? String,
              let datingRelationshipsArray = dictionary["dates"] as? [[String: Any]]
                
        else {
            return nil
        }
        self.boyId = boyId
        self.boysName = boysName
        self.boysCellNumber = boysCellNumber
        self.dates = datingRelationshipsArray.compactMap {DatingRelationship(dictionary: $0) }
    }
    */
/*
    func toDictionary() -> [String: Any] {
        return [
            "boyId": boyId,
            "boysName": boysName,
            "boysCellNumber": boysCellNumber,
            "dates": dates.map({$0.toDictionary()})
        ]
    }
 */



