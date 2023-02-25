//
//  SecondDatesDetailVC.swift
//  NasiShadchanHelper
//
//  Created by test on 2/23/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import Firebase

class SecondDatesDetailVC: UITableViewController {
    
    
    var selectedSecondDate: AppFirstDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "2nd Date Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save to 2nd Dates", style: .plain, target: self, action: #selector(saveToThirdDate))
        
    }
    
    @objc func saveToThirdDate() {
        let secondDateListRef  = Database.database().reference().child("AppThirdDates")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let mySecondDateListRef = secondDateListRef.child(uid)
        let myCurrentSecondDateRef = mySecondDateListRef.childByAutoId()
        
        let now = "\(Date())"
        let myThirdDate = AppFirstDate(boyID: selectedSecondDate.boyID, girlID: selectedSecondDate.girlID, dateCreated: now, boyFirstName: selectedSecondDate.boyFirstName, boyLastName: selectedSecondDate.boyLastName, girlFirstName: selectedSecondDate.girlFirstName, girlLastName: selectedSecondDate.girlLastName, girlImageDownloadString: selectedSecondDate.girlImageDownloadString, girlResumeDownlaodString: selectedSecondDate.girlResumeDownloadString, boySendResumeEmail: selectedSecondDate.boySendResumeEmail, boySendResumeText: selectedSecondDate.boySendResumeText, boyCell: selectedSecondDate.boyCell, boyPhotoImageURL: selectedSecondDate.boyPhotoImageURL)
        
        let dateDict = myThirdDate.toAnyObject()
        myCurrentSecondDateRef.setValue(dateDict)
        
        
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SecondDateCell", for: indexPath)
        let details = selectedSecondDate.boyLastName + " " + selectedSecondDate.girlLastName
        cell.textLabel?.text = details
        return cell
    }
}
