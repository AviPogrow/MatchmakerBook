//
//  SecondDatesDetailVC.swift
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

class SecondDatesDetailVC: FormViewController {
    
    
    var selectedSecondDate: MatchIdea!
    var moveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "2nd Date Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save 2nd Date", style: .plain, target: self, action: #selector(saveSecondDate))
        
        form +++

            Section("Name of Boy and Girl")

            <<< LabelRow () {
                //$0.title = "LabelRow"
                $0.title = selectedSecondDate.boyFirstName  + " " + selectedSecondDate.boyLastName + " & " + selectedSecondDate.girlFirstName + " " + selectedSecondDate.girlLastName
                }
              
        //section 1
    form  +++ Section("Date Of 2nd Date")

             <<< DateInlineRow() {
                 $0.title = "Choose Date"
                 
                 let secondDateWhenString = selectedSecondDate.dateOfSecondDate
                 let dateFormatter = DateFormatter()

                 // Set Date Format
                dateFormatter.dateFormat = "YY/MM/dd"
                let date = dateFormatter.date(from: secondDateWhenString)
                 $0.value  = date
                
             
        
            $0.onChange { [unowned self] row in
                
                let dateAsString = "\(row.value!)"
            self.selectedSecondDate.dateOfSecondDate = dateAsString ?? ""
            }
        }
    
        form    +++ Section("2nd Date Notes")

            <<< TextAreaRow() {
                $0.value = " " //selectedNasiBoy.shadchanNotes ?? ""
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 40)
                $0.onChange { [unowned self] row in //6
                //self.selectedSecondDate.secondDateNotes = row.value ??
                    ""
                }
            }
        
        form
        +++
        Section("What was the result?") //section 2
            <<< ActionSheetRow<String>() {
                $0.title = "Select Result"
                $0.selectorTitle = "Choose from Redds"
                $0.options = ["Boy said No","Girl said No","Both said YES"]
            
        $0.onChange { [unowned self] row in //6
           // self.selectedSecondDate.secondDateResult = row.value ??
          //  ""
        }
            }
        
        +++ Section("Move to 3rd Dates")
        <<< ViewRow<UIView>()
            .cellSetup { [self] (cell, row) in
            cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 88))
        
            let rect = CGRect(x: 0, y: 0, width: 0, height:0)
            moveButton = UIButton(frame: rect)
            moveButton.tag = 1001
            moveButton.setTitle(title: "Move to 3rd Dates List")
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
        selectedSecondDate.currentStage = "thirdDate"
        let dict = selectedSecondDate.toAnyObject()
        let ref = selectedSecondDate.ref
        ref?.updateChildValues(dict as! [AnyHashable : Any])
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    @objc func saveSecondDate() {
        //selectedSecondDate.dateOfSecondDate = dateOfSecondDate
        //selectedSecondDate.notesForSecondDate = notesForSecondDate
        //selectedSecondDate.resultOfSecondDate = resultOfSecondDate
        let now = "\(Date())"
        selectedSecondDate.timeStampForSecondDate = now
        
        let dict = selectedSecondDate.toAnyObject()
        let secondDateRef = selectedSecondDate.ref
        secondDateRef!.updateChildValues(dict as! [AnyHashable : Any])
        /*
        let now = "\(Date())"
        let myThirdDate = AppFirstDate(boyID: selectedSecondDate.boyID, girlID: selectedSecondDate.girlID, dateCreated: now, boyFirstName: selectedSecondDate.boyFirstName, boyLastName: selectedSecondDate.boyLastName, girlFirstName: selectedSecondDate.girlFirstName, girlLastName: selectedSecondDate.girlLastName, girlImageDownloadString: selectedSecondDate.girlImageDownloadString, girlResumeDownlaodString: selectedSecondDate.girlResumeDownloadString, boySendResumeEmail: selectedSecondDate.boySendResumeEmail, boySendResumeText: selectedSecondDate.boySendResumeText, boyCell: selectedSecondDate.boyCell, boyPhotoImageURL: selectedSecondDate.boyPhotoImageURL)
        
        let dateDict = myThirdDate.toAnyObject()
        myCurrentSecondDateRef.setValue(dateDict)
        */
        
    }
    
}
