//
//  ReddsDetailVC.swift
//  NasiShadchanHelper
//
//  Created by test on 2/28/23.
//  Copyright © 2023 user. All rights reserved.
//


import UIKit
import Eureka
import Firebase
import ImageRow
import ViewRow

class ReddsDetailVC: FormViewController {
    
    let reddListRef = Database.database().reference().child("shadchanNasiMatchIdea")
   
    var selectedRedd:MatchIdea!
    var allMatchesArray = [MatchIdea]()
    var namesArray = [String]()
    
    var moveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create an array of strings with boy and girl
        var tempNamesArray = [String]()
        //iterate over the array and pull the boys name
        for i in allMatchesArray {
            let boyFirstName = i.boyFirstName
            print(boyFirstName)
            
            let boyLastName = i.boyLastName
            let girlFirstName = i.girlFirstName
            let girlLastName = i.girlLastName
            let boyGirlNameString = boyFirstName + " " + boyLastName + " " + girlFirstName + " " + girlLastName
            tempNamesArray.append(boyGirlNameString)
            self.namesArray = tempNamesArray
        }
        
        
        navigationItem.title = "Redd Details"
        
 navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save Redd", style: .plain,
    target: self, action: #selector(saveRedd))

        form +++

            Section("Name of Boy and Girl")

            <<< LabelRow () {
            
                $0.title = selectedRedd.boyFirstName  + " " + selectedRedd.boyLastName + " & " + selectedRedd.girlFirstName + " " + selectedRedd.girlLastName
                }
        
        +++ Section("Move to 1st Dates")
        <<< ViewRow<UIView>()
            .cellSetup { [self] (cell, row) in
            cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 88))
        
            let rect = CGRect(x: 0, y: 0, width: 0, height:0)
            moveButton = UIButton(frame: rect)
            moveButton.tag = 1001
            moveButton.setTitle(title: "Move to 1st Dates List")
            moveButton.titleLabel?.font = .boldSystemFont(ofSize: 26)
                moveButton.backgroundColor = .systemPink
            cell.view!.addSubview(moveButton)
            moveButton.fillSuperview()
            moveButton.addTarget(self, action: #selector(self.handleMove), for: .touchUpInside)
            }
        
        
        //section 1
    form  +++ Section("Date Of Redd")

             <<< DateInlineRow() {
                 $0.title = "Choose Date"
                 $0.value = Date()
             }
        form
            +++
                Section("Redd to Who>") //section 2
            <<< ActionSheetRow<String>() {
                
                   $0.title = "Select an Option"
                // $0.selectorTitle = "Choose from Match Idea"
                $0.options = ["Both Boy & Girl","Boy not Girl","Girl not Boy"]
            }
        
        form
            +++
                Section("Level of Connection Between Shadchan and Girl") //section 2
            <<< ActionSheetRow<String>() {
                
                   $0.title = "Select an Option"
                // $0.selectorTitle = "Choose from Match Idea"
                $0.options = ["Never Met","Spoke once","Multiple Contacts"]
            }
        
        form
            +++
                Section("Redd Result") //section 2
            <<< ActionSheetRow<String>() {
                
                   $0.title = "Choose Result"
                // $0.selectorTitle = "Choose from Match Idea"
                $0.options = ["Girl Yes Boy No","Boy Yes Girl No","Waiting to hear from Boy","Both Said YES!"]
            }
        
        
            form    +++ Section("Redd Notes")

                <<< TextAreaRow() {
                    $0.value = " " //selectedNasiBoy.shadchanNotes ?? ""
                    $0.textAreaHeight = .dynamic(initialTextViewHeight: 60)
                }
        //section 1
    form  +++ Section("Date of Idea")

             <<< DateInlineRow() {
                 //$0.title = "Date Of Redd"
                 $0.value = Date()
             }
        
        form    +++ Section("Idea Notes")

            <<< TextAreaRow() {
                $0.value = " " //selectedNasiBoy.shadchanNotes ?? ""
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            }
        }
    
    @objc func handleMove() {
        
            //change the current stage to third date
            // so it filters out of the current list
            selectedRedd.currentStage = "firstDate"
            let dict = selectedRedd.toAnyObject()
            let ref = selectedRedd.ref
            ref?.updateChildValues(dict as! [AnyHashable : Any])
            self.navigationController?.popToRootViewController(animated: true)
            }

      
  @objc  func saveRedd() {
      
        
        
        let reddToSave = MatchIdea(boyID: selectedRedd.boyID, girlID: selectedRedd.girlID, dateCreated: "", boyFirstName: selectedRedd.boyFirstName, boyLastName: selectedRedd.boyLastName, girlFirstName: selectedRedd.girlFirstName, girlLastName: selectedRedd.girlLastName, girlImageDownloadString: selectedRedd.girlImageDownloadString, girlResumeDownlaodString: selectedRedd.girlResumeDownloadString, boySendResumeEmail: selectedRedd.boySendResumeEmail, boySendResumeText: selectedRedd.boySendResumeText, boyCell: selectedRedd.boyCell, boyPhotoImageURL: selectedRedd.boyPhotoImageURL, currentStage: "redd", timeStampForIdea: selectedRedd.timeStampForIdea, timeStampForRedd: selectedRedd.timeStampForRedd, timeStampForFirstDate: "", timeStampForSecondDate: selectedRedd.timeStampForSecondDate, timeStampForThirdDate: selectedRedd.timeStampForThirdDate, timeStampForFourthDate: selectedRedd.timeStampForFourthDate, dateOfFirstDate: "\(Date())", dateOfSecondDate: "", dateOfThirdDate: "", dateOfFourthDate: "")
        
        let dict = reddToSave.toAnyObject()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let myReddListRef = reddListRef.child(uid)
      
      let editState = editingMode()
      if editState == true {
          myReddListRef.updateChildValues(dict as! [AnyHashable : Any])
      } else {
      
      let newReddRef = myReddListRef.childByAutoId()
        newReddRef.setValue(dict)
      }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func editingMode()-> Bool {
        var editing = true
        if selectedRedd.boyLastName == "" {
            editing == false
        } else {
            editing == true
        }
        return editing
    }
    
    
}
