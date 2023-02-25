//
//  FirstDateDetailVC.swift
//  NasiShadchanHelper
//
//  Created by test on 2/23/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import Firebase

class FirstDateDetailVC: UITableViewController {
  
    var selectedFirstDate: AppFirstDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "1st Date Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save to 2nd Dates", style: .plain, target: self, action: #selector(handleSaveToSecond))
    }

    @objc func handleSaveToSecond() {
        let secondDateListRef  = Database.database().reference().child("AppSecondDates")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let mySecondDateListRef = secondDateListRef.child(uid)
        let myCurrentSecondDateRef = mySecondDateListRef.childByAutoId()
        
        let now = "\(Date())"
        let mySecondDate = AppFirstDate(boyID: selectedFirstDate.boyID, girlID: selectedFirstDate.girlID, dateCreated: now, boyFirstName: selectedFirstDate.boyFirstName, boyLastName: selectedFirstDate.boyLastName, girlFirstName: selectedFirstDate.girlFirstName, girlLastName: selectedFirstDate.girlLastName, girlImageDownloadString: selectedFirstDate.girlImageDownloadString, girlResumeDownlaodString: selectedFirstDate.girlResumeDownloadString, boySendResumeEmail: selectedFirstDate.boySendResumeEmail, boySendResumeText: selectedFirstDate.boySendResumeText, boyCell: selectedFirstDate.boyCell, boyPhotoImageURL: selectedFirstDate.boyPhotoImageURL)
        
        let dateDict = mySecondDate.toAnyObject()
        myCurrentSecondDateRef.setValue(dateDict)
    }


}
