//
//  ReddsDetailVC.swift
//  NasiShadchanHelper
//
//  Created by test on 2/23/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import Firebase


class ReddsDetailVC: UITableViewController {

    var selectedRedd: ShadchanRedd!
    
    @IBOutlet weak var boyGirlLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let boyName = selectedRedd.boyFirstName +
        " " + selectedRedd.boyLastName
        
        let girlName = selectedRedd.girlFirstName + " " + selectedRedd.girlLastName
        
        navigationItem.title = boyName + " " + girlName
        
        boyGirlLabel.text = boyName + " " + girlName
    
    }
    
    @IBAction func saveReddToDatesList(_ sender: Any) {
        let firstDateListRef  = Database.database().reference().child("AppFirstDates")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let myFirstDateListRef = firstDateListRef.child(uid)
        
        let newFirstDate = AppFirstDate(boyID: selectedRedd.boyID,
            girlID: selectedRedd.girlID,
            dateCreated: selectedRedd.dateCreated,
            boyFirstName: selectedRedd.boyFirstName,
            boyLastName: selectedRedd.boyLastName, girlFirstName: selectedRedd.girlFirstName,
            girlLastName: selectedRedd.girlLastName,
            girlImageDownloadString: selectedRedd.girlImageDownloadString, girlResumeDownlaodString: selectedRedd.girlResumeDownloadString,
            boySendResumeEmail: selectedRedd.boySendResumeEmail,
            boySendResumeText: selectedRedd.boySendResumeText,
            boyCell: selectedRedd.boyCell,
            boyPhotoImageURL: selectedRedd.boyPhotoImageURL)
        
        let dict = newFirstDate.toAnyObject()
        let newFirstDateRef = myFirstDateListRef.childByAutoId()
    
       newFirstDateRef.setValue(dict)
        self.navigationController?.popToRootViewController(animated: true)
    
    }
    
    /*
    func saveReddToFirstDates() {
        let firstDateListRef  = Database.database().reference().child("AppFirstDates")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let myFirstDateListRef = firstDateListRef.child(uid)
    
        
        let newFirstDate = AppFirstDate(boyID: selectedRedd.boyID,
            girlID: selectedRedd.girlID,
            dateCreated: selectedRedd.dateCreated,
            boyFirstName: selectedRedd.boyFirstName,
            boyLastName: selectedRedd.boyLastName, girlFirstName: selectedRedd.girlFirstName,
            girlLastName: selectedRedd.girlLastName,
            girlImageDownloadString: selectedRedd.girlImageDownloadString, girlResumeDownlaodString: selectedRedd.girlResumeDownloadString,
            boySendResumeEmail: selectedRedd.boySendResumeEmail,
            boySendResumeText: selectedRedd.boySendResumeText,
            boyCell: selectedRedd.boyCell,
            boyPhotoImageURL: selectedRedd.boyPhotoImageURL)
        
    }
     */
    /*
     `    //let dict = newFirstDate.toAnyObject()
        
           //let newFirstDateRef = myFirstDateListRef.childByAutoId()
       
          // newFirstDateRef.setValue(dict)
        
        
        //newFirstDateRef.setValue(dict)
       // self.navigationController?.popToRootViewController(animated: true)
    
        
   // }
     */

}
