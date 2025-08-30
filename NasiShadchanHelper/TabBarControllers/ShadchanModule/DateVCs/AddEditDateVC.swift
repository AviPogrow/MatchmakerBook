//
//  AddEditDateVC.swift
//  NasiShadchanHelper
//
//  Created by test on 11/13/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import ImageRow
import ViewRow

class AddEditDateVC: FormViewController, CreateBoyControllerDelegate, CreateGirlControllerDelegate {
   
   
    
    var isEditingDate = false
    var boysToSelectArray:[NasiBoy]!
    var girlsToSelectArray:[Girl]!
    var selectedNasiDate: NasiDate!
    let dateNumbers = [
        "0",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "10",
        "11",
        "12",
        "13",
        "14",
        "15",
        "16",
        "17",
        "18",
        "19",
        "20"
    ]
    
    let statuses = [
        "Idea",
        "Active",
        "Engaged",
        "Finished"]
    
    let programs = [
        "N/A",
        "Nasi List",
        "AY",
        "SC"]
    
    //use this label to set the boy name field value
    lazy var boyNameLabel = {
       let label = UILabel()
        label.text = "No Boy Profile"
        return label
    }()
    lazy var girlNameLabel = {
        let label = UILabel()
        label.text = "No Girl Profile"
        return label
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let myId = UserInfo.curentUser?.id else {return}
        

        
        print(isEditingDate)
        
        if isEditingDate == true {
       // if selectedNasiDate.ref  != nil { // editing
            let barButtonDelete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handleDelete))
            barButtonDelete.tintColor = UIColor.red
            
            let barButtonSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveDateToFirebase))
            
            navigationItem.rightBarButtonItems = [barButtonSave, barButtonDelete]
        } else {
            
            let barButtonSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveDateToFirebase))
            
            navigationItem.rightBarButtonItem = barButtonSave
        }
        
        form
            +++ Section("Select Boy Profile")
            <<< ViewRow<UIView>()
                .cellSetup { [self] (cell, row) in
                    cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 88))
                    cell.view?.backgroundColor = .cyan
                    let boyDobString = selectedNasiDate.boyDobString
                    let age = calculateAgeFromString(dobString: boyDobString)
                    let boysAge = selectedNasiDate.boysAge
                    
                    boyNameLabel.textAlignment = .center
                    boyNameLabel.numberOfLines = 0
                    
                    boyNameLabel.text = self.selectedNasiDate.boyLastName  + " " + self.selectedNasiDate.boyFirstName + " " + boysAge
                    
                    boyNameLabel.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action:
                    #selector(self.presentBoySelectionScene))
                    boyNameLabel.addGestureRecognizer(tapRecognizer)
                    cell.view?.addSubview(boyNameLabel)
                    boyNameLabel.fillSuperview()
                    boyNameLabel.adjustsFontSizeToFitWidth = true
                }
        
        
        form
            +++ Section("Select Girl Profile")
            <<< ViewRow<UIView>()
                .cellSetup { [self] (cell, row) in
                   cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 88))
                    cell.view?.backgroundColor = .systemPink.lighter()
                    let girlDobString = selectedNasiDate.girlDobString
                    
                    let girlAge = selectedNasiDate.girlAge
                    
                    
                    let age = calculateAgeFromString(dobString: girlDobString)
                    girlNameLabel.numberOfLines = 0
                    girlNameLabel.textAlignment = .center
                    
                    girlNameLabel.text = selectedNasiDate.girlFullName +  " " + girlAge
                    
                    
                    
                    girlNameLabel.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action:
                    #selector(self.presentGirlSelectionScene))
            girlNameLabel.addGestureRecognizer(tapRecognizer)
                    cell.view?.addSubview(girlNameLabel)
                   girlNameLabel.fillSuperview()
                    girlNameLabel.adjustsFontSizeToFitWidth = true
                
                
            }
        
        /*
        form
        +++
        Section("Select Girl Profile") //section 2
        <<< ActionSheetRow<String>() {
            $0.title = "Girls Full Name"
            $0.selectorTitle = "Scroll For More Options"
            $0.options = girlsToSelectArray
            $0.value = selectedNasiDate.girlFullName
            
            $0.onChange { [unowned self] row in
                let nameSeparate = row.value?.components(separatedBy: " ") ?? [""]
                var  lastName = nameSeparate.first
                var  firstName = nameSeparate.last
                selectedNasiDate.girlFullName = row.value ?? "NA"
                selectedNasiDate.girlFirstName = firstName!
                selectedNasiDate.girlLastName = lastName!
            }
        }
         */
        /*
        form +++ Section("Girls Age")
        <<< PhoneRow() {
            
            $0.placeholder = "Enter Girls Age"
            $0.value = selectedNasiDate.girlAge
            $0.onChange { [unowned self] row in
                self.selectedNasiDate?.girlAge = row.value ??
                "N/A"
            }
        }
        */
        form
        +++
        Section() //section 2
        <<< ActionSheetRow<String>() {
            $0.title = "Date Number"
            $0.selectorTitle = "Scroll For More Options"
            $0.value = selectedNasiDate.dateNumber
            $0.options = dateNumbers
            $0.onChange { [unowned self] row in
                self.selectedNasiDate?.dateNumber = row.value ??
                "N/A"
            }
        }
        form
        +++
        Section() //section 2
        <<< ActionSheetRow<String>() {
            $0.title = "Status"
            $0.selectorTitle = "Scroll For More Options"
            $0.options = statuses
            $0.value = selectedNasiDate.datingStatus
            $0.onChange { [unowned self] row in
                self.selectedNasiDate?.datingStatus = row.value ??
                "N/A"
            }
        }
        form
        +++
        Section() //section 2
        <<< ActionSheetRow<String>() {
            $0.title = "Program"
            $0.selectorTitle = "Scroll For More Options"
            $0.options = programs
            $0.value = selectedNasiDate.nasiProgram
            $0.onChange { [unowned self] row in
                self.selectedNasiDate?.nasiProgram = row.value ??
                "N/A"
            }
            
        }
        
        +++ Section("Shadchan Notes")
        
        <<< TextAreaRow() {
            $0.value = selectedNasiDate.shadchanNotes
            $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            $0.value = selectedNasiDate.shadchanNotes
            $0.onChange { [unowned self] row in //6
                self.selectedNasiDate.shadchanNotes = row.value ?? ""
            }
        }
        
    }
  
    func didAddGirl(girl: Girl) {
        
        
        let dobString = girl.dateOfBirthString
        let calcAge = calculateAgeFromString(dobString: dobString)
        print("the value of dobString is \(dobString) and calculated age is \(calcAge)")
        
        
        girlNameLabel.textAlignment = .center
        girlNameLabel.numberOfLines = 0
        girlNameLabel.text = girl.lastName + " " + girl.firstName + " "
        + girl.ageString
        //+
        //" - Age: " + "\(girl.calculatedAge)" + " - " + "xxx=xxx-xxxx"
        //update the girl properties of the selected Date
        selectedNasiDate.girlFullName = girl.lastName + " " + girl.firstName
        let fullName = selectedNasiDate.girlFullName
        let nameSeparate = fullName.components(separatedBy: " ") ?? [""]
        var  lastName = nameSeparate.first
        var  firstName = nameSeparate.last
        selectedNasiDate.girlFirstName = firstName!
        selectedNasiDate.girlLastName = lastName!
        //selectedNasiDate.girlCellNumber = girl.girlCell
        selectedNasiDate.girlDobString = girl.dateOfBirthString
        selectedNasiDate.girlAge = girl.ageString
        selectedNasiDate.girlKey = girl.key
        
        
        print("the girls key is \(girl.key)")
        
        
        tableView.reloadData()
        
    }
    func didAddBoy(boy: NasiBoy) {
        
        
    
        let dobString = boy.dobIntervalString
        let calcAge = calculateAgeFromString(dobString: dobString)
        
        boyNameLabel.textAlignment = .center
        boyNameLabel.numberOfLines = 0
        boyNameLabel.text = boy.boyLastName + " " + boy.boyFirstName + " " +
        " - Age: " + "\(calcAge)" //+ " - Cell: " + "xxx-xxx-xxxx"//boy.boyCell
        
        
        //update the boy property of the selected Date
        selectedNasiDate.boyFullName = boy.boyLastName + " " + boy.boyFirstName
        let fullName = selectedNasiDate.boyFullName
        let nameSeparate = fullName.components(separatedBy: " ") ?? [""]
        var  lastName = nameSeparate.first
        var  firstName = nameSeparate.last
        selectedNasiDate.boyFirstName = firstName!
        selectedNasiDate.boyLastName = lastName!
        selectedNasiDate.boyCellNumber = boy.boyCell
        selectedNasiDate.boyDobString = boy.dobIntervalString
        selectedNasiDate.boysAge = "\(calcAge)"
        selectedNasiDate.boyKey = boy.key
        
        tableView.reloadData()
    }
    func calculateAgeFromString(dobString: String) -> Double {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        let backToDate = dateFormatter.date(from: dobString) ?? Date()
    
                    
        let calculatedAge = calculateAgeFrom(dob: backToDate)
        
        return calculatedAge
    }
    func calculateAgeFrom(dob: Date) -> Double {
        
        let dateOfBirth = dob
        // get today as a date object and compare
        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year,.month, .day], from: dateOfBirth, to: today)
        
        let ageYears = components.year
        let decimal =  Double(components.month!) / Double(12)
        let compositeNumb = Double(ageYears!) + decimal
        let  roundedNumb =    Double(compositeNumb).rounded(toPlaces: 1)
        return roundedNumb
    }

   @objc func presentBoySelectionScene() {
        let selectBoyVC = SelectBoyVC()
       
       let sortedArray =  self.boysToSelectArray.sorted(by:    { $0.boyLastName < $1.boyLastName })
       
       selectBoyVC.boys = sortedArray
       selectBoyVC.boysToSelectArray = sortedArray
       selectBoyVC.delegate = self
       selectBoyVC.view.backgroundColor = .white
    self.navigationController?.pushViewController(selectBoyVC, animated: true)
    }
    
    @objc func presentGirlSelectionScene() {
        
        
         let selectGirlVC = SelectGirlVC()
        selectGirlVC.girls = girlsToSelectArray
        selectGirlVC.girlsToSelectArray = girlsToSelectArray
        selectGirlVC.delegate = self
        selectGirlVC.view.backgroundColor = .white
     self.navigationController?.pushViewController(selectGirlVC, animated: true)
     }
  
    @objc func handleDelete() {
        selectedNasiDate.ref?.removeValue()
        self.navigationController?.popViewController(animated: true)
    }
    
  @objc  func saveDateToFirebase() {
      
      let boyDobString = selectedNasiDate.boyDobString
      let boyAge = calculateAgeFromString(dobString: boyDobString)
      let girlDobString = selectedNasiDate.girlDobString
      let girlAge = calculateAgeFromString(dobString: girlDobString)
      print("value of boyDobString is \(boyDobString)")
      print("value of boyAge is \(boyAge)")
      
      print("value of girlDobString is \(girlDobString)")
      print("value of girlAge is \(girlAge)")
      
      
      
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
        
        let boyLastName = selectedNasiDate.boyLastName
        let boyFirstName = selectedNasiDate.boyFirstName
        let boyFullName = selectedNasiDate.boyFullName
        let boyDobString = selectedNasiDate.boyDobString
        let boysAge = selectedNasiDate.boysAge
        let boyCellNumber = selectedNasiDate.boyCellNumber
        let boyKey = selectedNasiDate.boyKey
        
        
        
        let girlDobString = selectedNasiDate.girlDobString
        let girlAge = selectedNasiDate.girlAge
        let girlCellNumber = selectedNasiDate.girlCellNumber
        let girlKey = selectedNasiDate.girlKey
        let girlLastName = selectedNasiDate.girlLastName
        let girlFirstName = selectedNasiDate.girlFirstName
        let girlFullName = selectedNasiDate.girlFullName
        
        let datingStatus = selectedNasiDate.datingStatus
        let dateNumber = selectedNasiDate.dateNumber
       
        let shadchanNotes = selectedNasiDate.shadchanNotes
        let nasiProgram = selectedNasiDate.nasiProgram
        let updateTimeStamp = Int(Date().timeIntervalSince1970)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
        var dateCreated = selectedNasiDate.dateCreated
       
        let revisedDate = NasiDate(boyFirstName: boyFirstName, boyLastName: boyLastName, boyFullName: boyFullName, boyKey: boyKey, boyCellNumber: boyCellNumber, boyDobString: boyDobString,boysAge: boysAge, dateNumber: dateNumber, datingStatus: datingStatus, girlFirstName: girlFirstName, girlLastName: girlLastName, girlFullName: girlFullName, girlKey: girlKey, girlDobString: girlDobString,girlAge:girlAge, girlCellNumber: girlCellNumber, shadchanNotes: shadchanNotes, dateCreated: dateCreated, dateLastUpdate: updateTimeStamp, nasiProgram: nasiProgram)
        let dict = revisedDate.toAnyObject()
        let ref = selectedNasiDate.ref
        ref?.updateChildValues(dict as! [AnyHashable : Any])
         
    }
    
    func createNewDateInFirebase() {
        
        let boyLastName = selectedNasiDate.boyLastName
        let boyFirstName = selectedNasiDate.boyFirstName
        let boyFullName = selectedNasiDate.boyFullName
        let girlLastName = selectedNasiDate.girlLastName
        let girlFirstName = selectedNasiDate.girlFirstName
        let girlFullName = selectedNasiDate.girlFullName
        let datingStatus = selectedNasiDate.datingStatus
        let dateNumber = selectedNasiDate.dateNumber
        let boyDobString = selectedNasiDate.boyDobString
        let boysAge = selectedNasiDate.boysAge
        let boyCellNumber = selectedNasiDate.boyCellNumber
        let boyKey = selectedNasiDate.boyKey
        let girlDobString = selectedNasiDate.girlDobString
        let girlAge = selectedNasiDate.girlAge
        
        let girlKey = selectedNasiDate.girlKey
        let girlCellNumber = selectedNasiDate.girlCellNumber
        let shadchanNotes = selectedNasiDate.shadchanNotes
        let nasiProgram = selectedNasiDate.nasiProgram
        
        
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let updateTimeStamp = Int(Date().timeIntervalSince1970)
        var dateFormatter = DateFormatter()
        
        var dateCreated = Date()
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
        let creationDateString = dateFormatter.string(from: dateCreated)
        
        let newDate = NasiDate(boyFirstName: boyFirstName,
                               boyLastName: boyLastName,
                               boyFullName: boyFullName,
                               boyKey: boyKey,
                               boyCellNumber: boyCellNumber,
                               boyDobString: boyDobString,
                               boysAge: boysAge,
                               dateNumber: dateNumber,
                               datingStatus: datingStatus,
                               girlFirstName: girlFirstName,
                               girlLastName: girlLastName,
                               girlFullName: girlFullName,
                               girlKey: girlKey,
                               girlDobString: girlDobString,
                               girlAge: girlAge,
                               girlCellNumber: girlCellNumber, shadchanNotes: shadchanNotes, dateCreated: creationDateString, dateLastUpdate: updateTimeStamp,
                               nasiProgram: nasiProgram)
        
        
        
        
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dateNodeRef = Database.database().reference().child("NasiDatesList").child(uid)
        
        let ref = dateNodeRef.childByAutoId()
        ref.setValue(newDate.toAnyObject())
        
    }
}
