//
//  FirstDateDetailVC.swift
//  NasiShadchanHelper
//
//  Created by test on 2/23/23.
//  Copyright © 2023 user. All rights reserved.
//
import UIKit
import Eureka
import Firebase
import ImageRow
import ViewRow

class FirstDateDetailVC: FormViewController {
  
    var selectedFirstDate: MatchIdea!
    
    var isInEditMode =  false
    var firstDatesArray = [MatchIdea]()
    
    var namesArray = [String]()
    var moveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "1st Date Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save 1st Date", style: .plain, target: self, action: #selector(handleSaveFirstDate))
        
        
        if selectedFirstDate != nil {
            isInEditMode = true
        }
        
       // if isInEditMode == false {
        var tempNamesArray = [String]()
        //iterate over the array and pull the boys name
        for i in firstDatesArray {
            
            
            let boyFirstName = i.boyFirstName
            print(boyFirstName)
            
            let boyLastName = i.boyLastName
            let girlFirstName = i.girlFirstName
            let girlLastName = i.girlLastName
            let boyGirlNameString = boyFirstName + " " + boyLastName + " " + girlFirstName + " " + girlLastName
            
            print(boyGirlNameString)
            
            tempNamesArray.append(boyGirlNameString)
        }
            self.namesArray = tempNamesArray
        
    //    }
        
        form +++

            Section("Name of Boy and Girl")

            <<< LabelRow () {
                //$0.title = "LabelRow"
                $0.title = selectedFirstDate.boyFirstName  + " " + selectedFirstDate.boyLastName + " & " + selectedFirstDate.girlFirstName + " " + selectedFirstDate.girlLastName
                }
              
        
        
        //section 1
    form  +++ Section("Date Of 1st Date")

             <<< DateInlineRow() {
                 $0.title = "Choose Date"
                 $0.value = Date()
             }
        
        form    +++ Section("1st Date Notes")

            <<< TextAreaRow() {
                $0.value = " " //selectedNasiBoy.shadchanNotes ?? ""
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 60)
            }
        
        +++ Section("Move to 2nd Dates")
        <<< ViewRow<UIView>()
            .cellSetup { [self] (cell, row) in
            cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 88))
        
            let rect = CGRect(x: 0, y: 0, width: 0, height:0)
            moveButton = UIButton(frame: rect)
            moveButton.tag = 1001
            moveButton.setTitle(title: "Move to 2nd Dates List")
            moveButton.titleLabel?.font = .boldSystemFont(ofSize: 26)
                moveButton.backgroundColor = .systemPink
            cell.view!.addSubview(moveButton)
            moveButton.fillSuperview()
            moveButton.addTarget(self, action: #selector(self.handleMove), for: .touchUpInside)
            }
        
    }
    @objc func handleMove() {
        
            //change the current stage to third date
            // so it filters out of the current list
            selectedFirstDate.currentStage = "secondDate"
            let dict = selectedFirstDate.toAnyObject()
            let ref = selectedFirstDate.ref
            ref?.updateChildValues(dict as! [AnyHashable : Any])
            self.navigationController?.popToRootViewController(animated: true)
            
        
        
    }
    @objc func handleSaveFirstDate() {
        let firstDateListRef  = Database.database().reference().child("shadchanNasiMatchIdea")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let myFirstDateListRef = firstDateListRef.child(uid)
        let myCurrentFirstDateRef = myFirstDateListRef.childByAutoId()
        
        let now = "\(Date())"
        /*
        let mySecondDate = AppFirstDate(boyID: selectedFirstDate.boyID, girlID: selectedFirstDate.girlID, dateCreated: now, boyFirstName: selectedFirstDate.boyFirstName, boyLastName: selectedFirstDate.boyLastName, girlFirstName: selectedFirstDate.girlFirstName, girlLastName: selectedFirstDate.girlLastName, girlImageDownloadString: selectedFirstDate.girlImageDownloadString, girlResumeDownlaodString: selectedFirstDate.girlResumeDownloadString, boySendResumeEmail: selectedFirstDate.boySendResumeEmail, boySendResumeText: selectedFirstDate.boySendResumeText, boyCell: selectedFirstDate.boyCell, boyPhotoImageURL: selectedFirstDate.boyPhotoImageURL)
        
        let dateDict = mySecondDate.toAnyObject()
        myCurrentFirstDateRef.setValue(dateDict)
         */
    }


}
