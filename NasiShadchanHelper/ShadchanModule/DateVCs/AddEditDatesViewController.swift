//
//  AddEditDatesViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 1/22/22.
//  Copyright © 2022 user. All rights reserved.
//

import UIKit
import Firebase

class AddEditDatesViewController: UITableViewController {

    @IBOutlet weak var boysFullNameTextField: UITextField!
    @IBOutlet weak var boysAgeTextField: UITextField!
    
    @IBOutlet weak var girlsFullNameTextField: UITextField!
    @IBOutlet weak var girlsAgeTextField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nasiProgramLabel: UILabel!
    
    @IBOutlet weak var shadchanNotesTextField: UITextView!
    @IBOutlet weak var numberOfDatesLabel: UILabel!
    
    var selectedNasiDate: NasiDate!
    var isEditingDate = false
    var datingStatus = "Idea"
    var programName = "N/A"
    var dateNumber = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       
        
        if selectedNasiDate != nil {
        let barButtonDelete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handleDelete))
        barButtonDelete.tintColor = UIColor.red
        
       let barButtonSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveDateToFirebase))
        
        navigationItem.rightBarButtonItems = [barButtonSave, barButtonDelete]
            
        } else {
            
            let barButtonSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveDateToFirebase))
            navigationItem.rightBarButtonItem = barButtonSave
        }
        
        
        
        if selectedNasiDate != nil {
            isEditingDate = true
            populateFields()
         
        }
       }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    
    @objc func handleDelete() {
        selectedNasiDate.ref?.removeValue()
        self.navigationController?.popViewController(animated: true)
    }
    
    func populateFields() {
        boysFullNameTextField.text = selectedNasiDate.boyFullName
        boysAgeTextField.text = selectedNasiDate.boysAge
        girlsFullNameTextField.text = selectedNasiDate.girlFullName
        girlsAgeTextField.text = selectedNasiDate.girlAge
        
        statusLabel.text = selectedNasiDate.datingStatus
        nasiProgramLabel.text = selectedNasiDate.nasiProgram
        shadchanNotesTextField.text = selectedNasiDate.shadchanNotes
        numberOfDatesLabel.text = selectedNasiDate.dateNumber
    }
    
  @objc  func saveDateToFirebase() {
        
        guard let mainView = navigationController?.parent?.view
            else { return }
          
        let hudView = HudView.hud(inView: view, animated: true)
         hudView.text = "Saved"
       
        if isEditingDate == true {
            updateDateInFireBase()
            
        } else {
          createNewDateInFirebase()
        }
        
        
        let delayInSeconds = 1.9
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds)
        {
         hudView.hide()
        self.navigationController?.popViewController(animated: true)
       }
    }
    
    func updateDateInFireBase() {
        let boyName = boysFullNameTextField.text ?? ""
        let girlName = girlsFullNameTextField.text ?? ""
        let datingStatus = statusLabel.text ?? ""
        let dateNumber = numberOfDatesLabel.text ?? ""
        let boyAge = boysAgeTextField.text ?? ""
        let girlAge = girlsAgeTextField.text ?? ""
        let shadchanNotes = shadchanNotesTextField.text ?? ""
        let nasiProgram = nasiProgramLabel.text ?? ""
        
        
        let updateTimeStamp = Int(Date().timeIntervalSince1970)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
        //dateFormatter.dateFormat =  "MM-dd-yyyy"//"hh:mm:ss a"
       
    
        var dateCreated = selectedNasiDate.dateCreated
        
        
        let revisedDate = NasiDate(boyFullName: boyName, boysAge: boyAge, dateNumber: dateNumber, datingStatus: datingStatus, girlFullName: girlName, girlAge: girlAge, shadchanNotes: shadchanNotes, dateCreated: dateCreated, dateLastUpdate: updateTimeStamp, nasiProgram: nasiProgram)
        
        let dict = revisedDate.toAnyObject()
        let ref = selectedNasiDate.ref
        ref?.updateChildValues(dict as! [AnyHashable : Any])
        
        
    }

    func createNewDateInFirebase() {
        
        let boyName = boysFullNameTextField.text ?? ""
        let girlName = girlsFullNameTextField.text ?? ""
        let datingStatus = statusLabel.text ?? ""
        let dateNumber = numberOfDatesLabel.text ?? ""
        let boyAge = boysAgeTextField.text ?? ""
        let girlAge = girlsAgeTextField.text ?? ""
        let shadchanNotes = shadchanNotesTextField.text ?? ""
        let nasiProgram = nasiProgramLabel.text ?? ""
        
        
        // create a time stamp by conversion to Int
        let timestamp = Int(Date().timeIntervalSince1970)
        let updateTimeStamp = Int(Date().timeIntervalSince1970)
        var dateFormatter = DateFormatter()
        
        var dateCreated = Date()
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
        let creationDateString = dateFormatter.string(from: dateCreated)
        
        let newDate = NasiDate(boyFullName: boyName, boysAge: boyAge, dateNumber: dateNumber, datingStatus: datingStatus, girlFullName: girlName, girlAge: girlAge, shadchanNotes: shadchanNotes, dateCreated: creationDateString, dateLastUpdate: updateTimeStamp, nasiProgram: nasiProgram)
        
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
       print("the uid is \(uid)")
        
        let dateNodeRef = Database.database().reference().child("NasiDatesList").child(uid)
        
        let ref = dateNodeRef.childByAutoId()
        ref.setValue(newDate.toAnyObject())
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender:
    Any?) {
      if segue.identifier == "PickStatus" {
        let controller = segue.destination as!
         StatusPickerViewController
          
        controller.selectedStatusName = statusLabel.text ?? ""
          
      } else if  segue.identifier == "PickDateNumber" {
          let controller = segue.destination as!
          DateNumberPIckerViewController
            
          controller.selectedDateNumber = numberOfDatesLabel.text ?? ""
          
       } else if segue.identifier == "PickProgram" {
          let controller = segue.destination as!
          ProgramPickerViewController
            
          controller.selectedProgramName = nasiProgramLabel.text ?? ""
      }
    }
    
    @IBAction func statusPickerDidPickStatus(
                      _ segue: UIStoryboardSegue) {
      let controller = segue.source as! StatusPickerViewController
      datingStatus = controller.selectedStatusName
      statusLabel.text = datingStatus
    }
    
    @IBAction func programPickerDidPickProgram(
                      _ segue: UIStoryboardSegue) {
      let controller = segue.source as! ProgramPickerViewController
      programName = controller.selectedProgramName
      nasiProgramLabel.text = programName
    }
    
    @IBAction func dateNumberPickerDidPickNumber(
                      _ segue: UIStoryboardSegue) {
                          
     let controller = segue.source as! DateNumberPIckerViewController
      dateNumber = controller.selectedDateNumber
      numberOfDatesLabel.text = dateNumber
      }

    @IBAction func donePressed(_ sender: Any) {
        saveDateToFirebase()
    }
    
}
