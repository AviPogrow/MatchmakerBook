//
//  AddEditGirlViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 2/12/23.
//  Copyright © 2023 user. All rights reserved.
//


import UIKit
import Eureka
import Firebase
import ImageRow
import ViewRow
import Contacts
import ContactsUI


class AddEditGirlViewController: FormViewController,CNContactPickerDelegate, ScannerViewControllerDelegate {
        
    func didScanAndParseResume(dict: [String: String]) {
        

        let firstName = dict["firstName"]
        let lastName = dict["lastName"]
        let phoneNumber = dict["telephone"]
        let city = dict["city"]
        let dob = dict["dob"]
        let height = dict["height"]
        
        let firstNameRow: TextRow? = form.rowBy(tag: "firstName") as? TextRow
        if let firstNameRow = firstNameRow {
            // Set the value of the TextRow
            firstNameRow.value = firstName
          // Update the UI to reflect the change
            firstNameRow.updateCell()
        }
        let secondNameRow: TextRow? = form.rowBy(tag: "lastName") as? TextRow
        if let secondNameRow = secondNameRow {
            secondNameRow.value = lastName
            secondNameRow.updateCell()
        }
        let cellRow: PhoneRow? = form.rowBy(tag: "cell") as? PhoneRow
        if let cellRow = cellRow {
            cellRow.value = phoneNumber
            cellRow.updateCell()
        }
        let cityRow: TextRow? = form.rowBy(tag: "city") as? TextRow
        if let cityRow = cityRow {
            cityRow.value = city
            cityRow.updateCell()
        }

    }
    
    var selectedShadchanGirl: ShadchanGirl!
    var isEditingGirl = true
    
    let initialHeight = Float(200.0)
    var notesImageView: UIImageView!
    var resumeImageView: UIImageView!
    var girlsPhotoImageView: UIImageView!
    var activeImageView = 1
    
    var datingHistory: String = ""
    var scanResumeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAddGirlOptions()
        navigationItem.title = "Profile Details"
        
        if selectedShadchanGirl != nil {
        let barButtonDelete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handleDelete))
        barButtonDelete.tintColor = UIColor.red
        
       let barButtonSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveGirlToFirebase))
        
        navigationItem.rightBarButtonItems = [barButtonSave, barButtonDelete]
            
        }
        else {
            
            let barButtonSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveGirlToFirebase))
            navigationItem.rightBarButtonItem = barButtonSave
        }

        self.tableView.backgroundColor = UIColor.white
        if selectedShadchanGirl == nil {
            isEditingGirl = false
            initNewNasiGirl()
    }
        
        
        //1 section 0
      form +++ Section("Girls Name")
        <<< TextRow() {
            $0.tag = "firstName"
            $0.placeholder = "First Name"
            
            $0.value = selectedShadchanGirl?.girlFirstName ?? ""
            $0.onChange { [unowned self] row in //6
                 self.selectedShadchanGirl?.girlFirstName  = row.value ?? ""
             }
          }
        
         <<< TextRow() {
            $0.placeholder = "Last Name"
             $0.tag = "lastName"
             $0.value = selectedShadchanGirl?.girlLastName ?? ""
           $0.onChange { [unowned self] row in //6
        self.selectedShadchanGirl?.girlLastName = row.value ??
               ""
           }
       }
        form +++ //section 3
            Section("Girls Cell")
            
            <<< PhoneRow(){
                $0.title = "Cell"
                $0.tag = "cell"
                $0.placeholder = "Add numbers here"
                $0.value =
                self.selectedShadchanGirl?.girlCell ?? "N/A"
                
                $0.onChange { [unowned self] row in
                    self.selectedShadchanGirl?.girlCell = row.value ??
                    "N/A"
                }
            }
        
        
        form +++ Section("Girls City")
        <<< TextRow() {
            $0.tag = "city"
           $0.placeholder = "City"
            $0.value = selectedShadchanGirl?.city ?? ""
          $0.onChange { [unowned self] row in //6
  self.selectedShadchanGirl?.city = row.value ?? ""
          }
      }
        
        form +++ Section("Girls Age")
        <<< PhoneRow() {
            
            $0.placeholder = "Enter Girls Age"
          
             let dobIntervalString = selectedShadchanGirl.dobIntervalString ?? ""
            let girlAge = self.selectedShadchanGirl.calculateAgeFrom(dobString: dobIntervalString)
             $0.value = "\(girlAge)"
             
            $0.onChange { [unowned self] row in
    self.selectedShadchanGirl?.ageEntered = Int(row.value ?? "0") ?? 0
        
    //convert age to dob
    let dob = dobByAddingYears(numberOfYears: self.selectedShadchanGirl.ageEntered)
    print(dob)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YY/MM/dd"
    let dobString = dateFormatter.string(from: dob)
    print(dobString)
    self.selectedShadchanGirl.dobIntervalString = dobString
            
    }
        }
       
        
        
        /*
        //section 1
    form  +++ Section()

             <<< DateInlineRow() {
                 $0.title = "Date Of Birth"
            
            if selectedShadchanGirl == nil {
                $0.value = Date()
            }
                 
            if selectedShadchanGirl != nil {
                // take the interval string and convert it back to
                // int
                let intervalAsInt = Int(selectedShadchanGirl.dobIntervalString)
                let intervalAsDouble = Double(selectedShadchanGirl.dobIntervalString) ?? 0.0
                // convert the Int interval to a date object and
                // set the picker
                
                
                let dobString = selectedShadchanGirl.dobIntervalString
                
                let dateFormatter = DateFormatter()

                // Set Date Format
               dateFormatter.dateFormat = "YY/MM/dd"
               let date = dateFormatter.date(from: dobString)
                
                //after converting the string into a date
                // we can set the value of the date picker
                $0.value  = date
                
                
                $0.onChange { [unowned self] row in //6
                   // self.selectedNasiBoy?.dob = row.value!
                    
                // get date from picker
                let birthday = row.value!
                let dateOfBirth = birthday // get the date object
                    
                // Create Date Formatter
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YY/MM/dd"
                let dateOfBirthString = dateFormatter.string(from: dateOfBirth)
                    
                // calculate age from date of birth
                var currentage = calculateAgeFrom(dob: row.value!)
                    
                // convert date to INt interval
                let interval = Int(birthday.timeIntervalSince1970)
                    
                // wrap Int as a string
                let dobIntervalString = "\(interval)"
                
                // convert Interval string back to Int
                let intervalBackToInt = Int(string: dobIntervalString)
                    
                    if selectedShadchanGirl != nil {
                self.selectedShadchanGirl.dobIntervalString = dateOfBirthString
            
                    
                //self.selectedNasiBoy.calculatedAge = "\(currentage)"
            }
                
            }
        }
        }
       */
        //section 2
    form
        +++
            Section() //section 2
        <<< ActionSheetRow<String>() {
            $0.tag = "height"
            $0.title = "Girls Height"
            $0.selectorTitle = "Scroll For More Options"
            $0.options = ["4'10\"","4'11\"","5'0\"","5'1\"","5'2\"","5'3\"","5'4\"","5'5\"","5'6\"","5'7\"","5'8\"","5'9\"","5'10\"","5'11\"","6'0\"","6'1\"","6'2\"","6'3\"","N/A\""]
           
            $0.value = self.selectedShadchanGirl?.girlHeight ?? "N/A"
            $0.onChange { [unowned self] row in
            self.selectedShadchanGirl?.girlHeight = row.value ??
                "N/A"
            }
        }
          
        
        form
            +++
                Section() //section 2
            <<< ActionSheetRow<String>() {
                $0.title = "Girls Status"
                
                $0.selectorTitle = "Choose a Status"
                $0.options = ["available","engaged"]
               
                $0.value = self.selectedShadchanGirl?.status ?? "available"
                $0.onChange { [unowned self] row in
                self.selectedShadchanGirl?.status = row.value ??
                    "available"
                }
            }
        //section  4
        form +++ SelectableSection<ImageCheckRow<String>>("Boy Categories - Check All That Apply", selectionType: .multipleSelection)
                                                                
        let girlCategories = ["FTL - 1-3",
                                  "FTL - 3-5",
                                  "FTL - 5",
                                  "FTL - 5-7",
                                  "FTL - 7+",
                                  "PTL - School",
                                  "PTL - Working",
                                  "FTW/College-Yeshiva Style",
                                  "FTW/College-Not Yeshiva Style"]
        
        
        for option in girlCategories {
            form.last! <<< ImageCheckRow<String>(){ lrow in
                lrow.title = option
                lrow.selectableValue = option
                let currentElement = option
                
                let arry = selectedShadchanGirl.categories
                let check = arry.contains(currentElement)
                
                if check == true {
                
                lrow.value =  currentElement
                } else {
                    lrow.value = nil
                }
            }.cellSetup { cell, _ in
                cell.trueImage = UIImage(named: "selectedRectangle")!
                cell.falseImage = UIImage(named: "unselectedRectangle")!
                cell.accessoryType = .checkmark
        }
            
        }
        
        form +++ Section("Send Resume/Contact Info")
             <<< TextRow() {
                 $0.tag = "email"
               $0.placeholder = "Email"
                 $0.value = selectedShadchanGirl?.sendResumeEmail  //5
                 
               $0.onChange { [unowned self] row in //6
                   self.selectedShadchanGirl?.sendResumeEmail = row.value ?? ""
               }
            }
        <<< PhoneRow() {
           
           $0.placeholder = "Cell"
             $0.value = selectedShadchanGirl?.sendResumeText  //5
        
           $0.onChange { [unowned self] row in //6
               self.selectedShadchanGirl?.sendResumeText = row.value ?? ""
           }
        }
        +++ Section("Dating History")
        <<< TextRow() {
            $0.value = self.datingHistory
        }
           
     
       
        +++ Section("Shadchan Notes")

        <<< TextAreaRow() {
            $0.value = selectedShadchanGirl.shadchanNotesNew
            
            $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            
            $0.onChange { [unowned self] row in //6
                self.selectedShadchanGirl?.shadchanNotesNew = row.value ?? ""
            }
    }
        +++ Section("Photo of Notes")
        <<< ViewRow<UIView>()
        .cellSetup { (cell, row) in
            //  Construct the view - in this instance the a rudimentry view created here
            cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
            cell.view!.backgroundColor = UIColor.orange
            
            let rect = CGRect(x: 0, y: 0, width: 150, height:200)
            let editImageView = UIImageView(frame: rect)
            editImageView.isUserInteractionEnabled = true
            editImageView.tag = 101
            
            editImageView.backgroundColor = .white
            cell.view!.addSubview(editImageView)
            
            editImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.pickPhoto)))
            let rect2 = CGRect(x: 150, y: 0, width: 200, height: 200)
            self.notesImageView = UIImageView(frame: rect2)
            cell.view?.addSubview(self.notesImageView)
            self.notesImageView.contentMode = .scaleAspectFit
            self.notesImageView.backgroundColor = UIColor.groupTableViewBackground
            self.notesImageView.isUserInteractionEnabled = true
            self.notesImageView.layer.cornerRadius = 17
            self.notesImageView.layer.borderWidth = 2.0
            self.notesImageView.layer.borderColor = UIColor.red.cgColor
            self.notesImageView.clipsToBounds = true
            
            let imageURL = self.selectedShadchanGirl.notesImageURL ?? ""
            
            cell.view!.backgroundColor = UIColor.white
            
            self.notesImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleZoomTap)))
            self.notesImageView.loadImageFromUrl(strUrl: imageURL, imgPlaceHolder: "")
            
            let rect3 = CGRect(x: 16, y: 16, width: 90, height: 90)
            let label = UILabel(frame: rect3)
            label.adjustsFontSizeToFitWidth
            label.textColor = .systemBlue
            label.text = "Edit Image"
            cell.view!.addSubview(label)
            
        }
        
        +++ Section("Photo of Resume")
        <<< ViewRow<UIView>()
        .cellSetup { (cell, row) in
            //  Construct the view - in this instance the a rudimentry view created here
            cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
            cell.view!.backgroundColor = UIColor.orange
            
            let rect = CGRect(x: 0, y: 0, width: 150, height: 200)
            let editImageView = UIImageView(frame: rect)
            editImageView.isUserInteractionEnabled = true
            editImageView.tag = 102
            
            editImageView.backgroundColor = .white
            cell.view!.addSubview(editImageView)
            
            editImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.pickPhoto)))
            let rect2 = CGRect(x: 150, y: 0, width: 200, height: 200)
            self.resumeImageView = UIImageView(frame: rect2)
            cell.view?.addSubview(self.resumeImageView)
            self.resumeImageView.contentMode = .scaleAspectFit
            self.resumeImageView.isUserInteractionEnabled = true
            self.resumeImageView.layer.cornerRadius = 17
            self.resumeImageView.layer.borderWidth = 2.0
            self.resumeImageView.layer.borderColor = UIColor.red.cgColor
            self.resumeImageView.clipsToBounds = true
            let imageURL = self.selectedShadchanGirl.resumeImageURL ?? ""
            
            cell.view!.backgroundColor = UIColor.white
            self.resumeImageView.backgroundColor = UIColor.groupTableViewBackground
            self.resumeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleZoomTap)))
            self.resumeImageView.loadImageFromUrl(strUrl: imageURL, imgPlaceHolder: "")
            
            
            let rect3 = CGRect(x: 16, y: 16, width: 90, height: 90)
            let label = UILabel(frame: rect3)
            label.adjustsFontSizeToFitWidth
            label.textColor = .systemBlue
            label.text = "Edit Image"
            cell.view!.addSubview(label)
            
        }
        
        
       
    
        +++ Section("Girls Profile Image")
        <<< ViewRow<UIView>()
        .cellSetup { (cell, row) in
            //  Construct the view - in this instance the a rudimentry view created here
            cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
            cell.view!.backgroundColor = UIColor.orange
            
            let rect = CGRect(x: 0, y: 0, width: 150, height:200)
            let editImageView = UIImageView(frame: rect)
            editImageView.isUserInteractionEnabled = true
            editImageView.tag = 103
            
            editImageView.backgroundColor = .white
            cell.view!.addSubview(editImageView)
            
            editImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.pickPhoto)))
            let rect2 = CGRect(x: 150, y: 0, width: 200, height: 200)
            self.girlsPhotoImageView = UIImageView(frame: rect2)
            cell.view?.addSubview(self.girlsPhotoImageView)
            self.girlsPhotoImageView.backgroundColor = UIColor.groupTableViewBackground
            self.girlsPhotoImageView.contentMode = .scaleAspectFit
            self.girlsPhotoImageView.isUserInteractionEnabled = true
            self.girlsPhotoImageView.layer.cornerRadius = 17
            self.girlsPhotoImageView.clipsToBounds = true
            self.girlsPhotoImageView.layer.borderWidth = 2.0
            self.girlsPhotoImageView.layer.borderColor = UIColor.red.cgColor
            let imageURL = self.selectedShadchanGirl.photoImageURL ?? ""
            
            cell.view!.backgroundColor = UIColor.white
            self.girlsPhotoImageView.image = UIImage(named: "selected")
            self.girlsPhotoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleZoomTap)))
            self.girlsPhotoImageView.loadImageFromUrl(strUrl: imageURL, imgPlaceHolder: "")
            
            let rect3 = CGRect(x: 16, y: 16, width: 90, height: 90)
            let label = UILabel(frame: rect3)
            label.adjustsFontSizeToFitWidth
            label.textColor = .systemBlue
            label.text = "Edit Image"
            cell.view!.addSubview(label)
            
        }
        +++ Section("Scan Resume Basic Camera")
        <<< ViewRow<UIView>()
            .cellSetup { [self] (cell, row) in
                cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 88))
                
                let rect = CGRect(x: 0, y: 0, width: 0, height:0)
                scanResumeButton = UIButton(frame: rect)
                scanResumeButton.tag = 1001
                scanResumeButton.setTitle(title: "Scan Resume Basic Camera")
                scanResumeButton.titleLabel?.font = .boldSystemFont(ofSize: 26)
                cell.view!.addSubview(scanResumeButton)
                scanResumeButton.fillSuperview()
                scanResumeButton.addTarget(self, action: #selector(self.handleScanResumeWithBasicCamera), for: .touchUpInside)
                scanResumeButton.backgroundColor = .green
                scanResumeButton.isEnabled = true
            }
        
        +++ Section("Scan Resume Doc Scanner")
        <<< ViewRow<UIView>()
            .cellSetup { [self] (cell, row) in
                cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 88))
                
                let rect = CGRect(x: 0, y: 0, width: 0, height:0)
                scanResumeButton = UIButton(frame: rect)
                scanResumeButton.tag = 1001
                scanResumeButton.setTitle(title: "Scan Resume Doc Scanner")
                scanResumeButton.titleLabel?.font = .boldSystemFont(ofSize: 26)
                cell.view!.addSubview(scanResumeButton)
                scanResumeButton.fillSuperview()
                scanResumeButton.addTarget(self, action: #selector(self.handleScanResumeWithDocScanner), for: .touchUpInside)
                scanResumeButton.backgroundColor = .systemCyan
                scanResumeButton.isEnabled = true
            }
           
    }
    
    
  
    
    func handleAddManually() {
      //  let addEditController = AddEditGirlViewController()
      //  label.isHidden = true
     //   navigationController?.pushViewController(addEditController, animated: true)
     //   searchBar.isHidden = true
        
    }
    func importFromContacts() {
        let store = CNContactStore()
        switch
        CNContactStore.authorizationStatus(for: .contacts) {
        
        case .authorized:
            self.presentContactPicker()
                        
        case .notDetermined:
        //request access
        store.requestAccess(for: .contacts) { (granted, error) in
                if granted {
                    self.presentContactPicker()
                } else {
                      self.showAccessDeniedAlert()
                }
            }
        default :
            self.showAccessDeniedAlert()
            
        }
    }
    
    func showAccessDeniedAlert() {
        let alert = UIAlertController(title: "Contacts Access Denied" , message: "Please enable contacts access in settings in Settings to import contacts.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        present(alert, animated: true)
    }
        
    
func presentContactPicker() {
    
    let contactPickerVC = CNContactPickerViewController()
    
    contactPickerVC.delegate = self
    contactPickerVC.displayedPropertyKeys =
    [CNContactGivenNameKey,
     CNContactFamilyNameKey,
     CNContactPhoneNumbersKey,
    CNContactEmailAddressesKey]
    present(contactPickerVC, animated: true)
     
}
func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
  importContact(contact)
}
func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
    dismiss(animated: true)
}
func importContact(_ contact: CNContact){
    let firstName = "\(contact.givenName)"
    let lastName = "\(contact.familyName)"
    let phoneNumbers = contact.phoneNumbers.map({$0.value as CNPhoneNumber})
    let cellNumber = "\(phoneNumbers.first!.stringValue)"
    let emails = contact.emailAddresses.map({$0.value as String})
    let email = "\(emails.first!)"
    
    let address = contact.postalAddresses.first?.value as? CNPostalAddress
    let city = "\(address?.city ?? "Not Found")"
    
    let height = "\(contact.note ?? "No Note")"
    
    print("imported contact: \(firstName), \(phoneNumbers), \(emails)")
    
    let firstNameRow: TextRow? = form.rowBy(tag: "firstName") as? TextRow
    if let firstNameRow = firstNameRow {
        // Set the value of the TextRow
        firstNameRow.value = firstName
      // Update the UI to reflect the change
        firstNameRow.updateCell()
    }
    let secondNameRow: TextRow? = form.rowBy(tag: "lastName") as? TextRow
    if let secondNameRow = secondNameRow {
        secondNameRow.value = lastName
        secondNameRow.updateCell()
    }
    let cellRow: PhoneRow? = form.rowBy(tag: "cell") as? PhoneRow
    if let cellRow = cellRow {
        cellRow.value = cellNumber
        cellRow.updateCell()
    }
    let cityRow: TextRow? = form.rowBy(tag: "city") as? TextRow
    if let cityRow = cityRow {
        cityRow.value = city
        cityRow.updateCell()
    }
    
    
 
    
}
    @objc func showAddGirlOptions() {
        let alert = UIAlertController(title: "Add Girl", message: "Choose how you'd like to add a girl", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Add Manually", style: .default, handler: { (_) in
            self.handleAddManually()
        }))
        
        alert.addAction(UIAlertAction(title: "Import From Contacts", style: .default, handler: { (_) in
            self.importFromContacts()
        }))
        alert.addAction(UIAlertAction(title: "Scan Resume", style: .default, handler: { (_) in
            self.handleScanResumeWithDocScanner()
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert,animated: true)
    }
    
    
    @objc func handleScanResumeWithBasicCamera() {
        let resumeScannerVC = ResumeScannerViewController()
        self.navigationController?.pushViewController(resumeScannerVC, animated: true)
       }
    @objc func handleScanResumeWithDocScanner() {
        let docScannerVC = ScannerViewController()
        docScannerVC.delegate = self
        self.navigationController?.pushViewController(docScannerVC, animated: true)
       }
    
    
    func dobByAddingYears(numberOfYears: Int) -> Date {
        let currentDate = Date()
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = -numberOfYears
        dateComponents.month = -6
        let pastDate = calendar.date(byAdding: dateComponents, to: currentDate)
        let timenterval = pastDate?.timeIntervalSinceNow
        
        return pastDate!
    }
    
    
    func simplifyCategoriesDisplay() {
        let girlCategories = ["FTL - 1-3",
                                  "FTL - 3-5",
                                  "FTL - 5",
                                  "FTL - 5-7",
                                  "FTL - 7+",
                                  "PTL - School",
                                  "PTL - Working",
                                  "FTW/College-Yeshiva Style",
                                  "FTW/College-Not Yeshiva Style"]
        
        
        // creat4e empty array to hold results
        //iterate over array of categories
        // if element contains "FTL or "PTC"
        // then add "FTL to new array
        // then remove duplicates from Array
        let emptyArray  = [String]()
       // let currentCatArray =
    }
    
    @objc func  pickPhoto(_ tapGesture: UITapGestureRecognizer){
        if let imageView = tapGesture.view as? UIImageView {
            
            print("the imageView is \(imageView.debugDescription)")
            if imageView.tag == 103 { // boys photo
                    activeImageView = 3
            } else if imageView.tag == 102 {
                activeImageView = 2
            } else if imageView.tag == 101 {
                activeImageView = 1
                    
                }
            }
        
        
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
        showPhotoMenu()
      } else {
        choosePhotoFromLibrary()
      }
    }
    
    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            //PRO Tip: don't perform a lot of custom logic inside of a view class
            self.performZoomInForStartingImageView(imageView)
        }
    }

    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    //my custom zooming logic
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        

        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.groupTableViewBackground
        self.girlsPhotoImageView.layer.cornerRadius = 17
        self.girlsPhotoImageView.clipsToBounds = true
        self.girlsPhotoImageView.layer.borderWidth = 2.0
        self.girlsPhotoImageView.layer.borderColor = UIColor.red.cgColor
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.contentMode = .scaleAspectFit
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        var pinchGesture  = UIPinchGestureRecognizer()
        //pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pincheGestureHandler))
 
        //zoomingImageView.addGestureRecognizer(pinchGesture)
        
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                //self.inputContainerView.alpha = 0
                
                // math?
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
                }, completion: { (completed) in
//                    do nothing
            })
            
        }
    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
               // self.inputContainerView.alpha = 1
                
                }, completion: { (completed) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingImageView?.isHidden = false
            })
        }
    }
            

    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
        
        let section = row.section!.index!
     if section == 6 {
         var values = (row.section as! SelectableSection<ImageCheckRow<String>>).selectedRows().map({$0.baseValue!}) as! [String]
          print(values)
         
         self.selectedShadchanGirl.categories = values
         
         
         
         //simplifyCategoriesDisplay()
         //invoke function that simplifies categories and assign it
         //self.selectedShadchanGirl.simplifiedCategories =
         }
    }
        
    
    @objc func handleAdd() {
        let AddEditController = AddEditGirlViewController()
        
        navigationController?.pushViewController(AddEditController, animated: true)
    }
    
   
    func initNewNasiGirl() {
        let dateCreated  = Date()
    
    let updateTimeStamp = Int(Date().timeIntervalSince1970)
        let dateFormatter = DateFormatter()
        // Set Date Format
        dateFormatter.dateFormat = "YY/MM/dd"
        let dateCreatedString = dateFormatter.string(from: dateCreated)
    
    
        self.selectedShadchanGirl = ShadchanGirl(girlCell: "", girlLastName: "", girlFirstName: "",city: "", calculatedAge: "",ageEntered: 0, dobIntervalString: "", dateCreated: dateCreatedString, dateLastUpdate: updateTimeStamp, girlHeight: "", sendResumeEmail: "", sendResumeText: "", categories: ["",""],status: "available",datingHistory:"", shadchanNotesNew: "", shadchanNotes: "", notesImageURL: "", resumeImageURL: "", photoImageURL: "")
       
    }
    
    @objc func saveGirlToFirebase() {
         guard let mainView = navigationController?.parent?.view
             else { return }
           //let hudView = HudView.hud(inView: mainView, animated: true)
           //hudView.text = "Saved"
         
      
         if isEditingGirl == true {
             
             //update the lastUpdate property
         let updateTimeStamp = Int(Date().timeIntervalSince1970)
         self.selectedShadchanGirl.dateLastUpdate = updateTimeStamp
         saveSelectedShadchanGirlToFB()
         } else {
             saveSelectedShadchanGirlToFB()
         }
         
         let delayInSeconds = 0.6
         DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds)
         {
            // hudView.removeFromSuperview()
            self.navigationController?.popToRootViewController(animated: true)
         }
     }
    
    func saveSelectedShadchanGirlToFB() {
        
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if selectedShadchanGirl.ref != nil {
        let shadchanGirlRef = selectedShadchanGirl.ref!
        
        // since we have the full referece we can reset the value
        // at that location and it will update
        shadchanGirlRef.setValue(selectedShadchanGirl.toAnyObject())
           
        } else { // if no referece exists then we are creating a new object
            
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // go to the private girls list and find the current user's list
        // which will be under their uid
        let shadchanGirlNodeRef = Database.database().reference().child("PrivateGirlsList").child(uid)
            
            // add a child node with a UID to put the new girl under
            let newNasiGirlRef = shadchanGirlNodeRef.childByAutoId()
            // convert the girl object to dictionary and add it
            newNasiGirlRef.setValue(selectedShadchanGirl.toAnyObject())
            }
        }
    
    @objc func handleDelete() {
        selectedShadchanGirl.ref?.removeValue()
        self.navigationController?.popToRootViewController(animated: true)
        
    }

}
extension AddEditGirlViewController:
UIImagePickerControllerDelegate,
  UINavigationControllerDelegate {
  
    // MARK: - Image Helper Methods
  func takePhotoWithCamera() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .camera
    imagePicker.delegate = self
      imagePicker.modalPresentationStyle = .popover
    imagePicker.allowsEditing = false
      
      
      let ppc = imagePicker.popoverPresentationController
      ppc?.sourceView = self.girlsPhotoImageView
      ppc?.permittedArrowDirections = .any
    present(imagePicker, animated: true, completion: nil)
}
    
    func choosePhotoFromLibrary() {
        
        let imagePicker = UIImagePickerController()
      imagePicker.sourceType = .photoLibrary
      imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
      imagePicker.allowsEditing = false
        
        
        let ppc = imagePicker.popoverPresentationController
        ppc?.sourceView = self.girlsPhotoImageView
        //ppc?.sourceRect = self.boysPhotoImageView.frame
        ppc?.permittedArrowDirections = .any
        present(imagePicker, animated: true)
    }
    
    // MARK: - Image Picker Delegates
    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info:
    [UIImagePickerController.InfoKey: Any] ){
        let image = info[UIImagePickerController.InfoKey.originalImage] as?
    UIImage
      if let theImage = image {
          
          print("value of active image View is \(activeImageView)")
          
          
          
          
          var identifier = ""
          if activeImageView == 3 {
          self.girlsPhotoImageView.image = theImage
          identifier = "photoImageURL"
          }
          else if activeImageView == 2 {
              self.resumeImageView.image = theImage
              identifier = "resumeImageURL"
          } else if activeImageView == 1 {
              self.notesImageView.image = theImage
              identifier = "notesImageURL"
              
              
              
              
              
          }
          
          self.uploadImageAndGetURLAndSetInstanceVar(image: theImage, identifier: identifier)
        }
      dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(
      _ picker: UIImagePickerController
    ){
      dismiss(animated: true, completion: nil)
    }

   

    func showPhotoMenu() {
        

        let alert = UIAlertController(
        title: nil,
        message: nil,
        preferredStyle: .actionSheet)
        
        let actCancel = UIAlertAction(
        title: "Cancel",
        style: .cancel,
        handler: nil)
        alert.addAction(actCancel)
        
    let actPhoto = UIAlertAction(
          title: "Take Photo",
          style: .default)
        { _ in
            self.takePhotoWithCamera()
        }
      alert.addAction(actPhoto)
        
        let actLibrary = UIAlertAction(
          title: "Choose From Library",
          style: .default)
        { _ in
           self.choosePhotoFromLibrary()
          }
        alert.addAction(actLibrary)
            
        self.girlsPhotoImageView
        
        if let popView = alert.popoverPresentationController {
            popView.sourceView = self.girlsPhotoImageView
            popView.sourceRect = self.girlsPhotoImageView.frame
        
        present(alert, animated: true, completion: nil)
        } else {
            present(alert, animated: true)
        }
    }

    
    func show(image: UIImage) {
       // boyProfileImageImageView.image = image
       // boyProfileImageImageView.isHidden = false
      //addPhotoLabel.text = ""
    }
    
    func uploadImageAndGetURLAndSetInstanceVar(image: UIImage, identifier: String) {
        
        self.view.showLoadingIndicator()
        
        print("upload image invoked - image state is \(image)")
        // convert image to jpeg data
        guard let uploadData = image.jpegData(compressionQuality: 0.1) else { return }
        
        let filename = NSUUID().uuidString
        print("the fileName is \(filename)")
        
        let storageRef = Storage.storage().reference().child("test_girl_profile_images").child(filename)
        
        storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
            
            if let err = err {
                
                print("Failed to upload post image:", err)
                return
            
            }
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err {
                    
                print("Failed to fetch downloadURL:", err)
                    return
                    
                }
                
                guard let imageUrl = downloadURL?.absoluteString else { return }
                
                print("Successfully uploaded post image:", imageUrl)
                
                
                if identifier == "notesImageURL" {
                 self.selectedShadchanGirl.notesImageURL = imageUrl
                    
                } else if identifier == "resumeImageURL" {
                    self.selectedShadchanGirl.resumeImageURL = imageUrl
                    
                } else if identifier == "photoImageURL" {
                    self.selectedShadchanGirl.photoImageURL = imageUrl
                    
                }
            
                self.view.hideLoadingIndicator()
            })
        }
    }
    
    // pass the url string
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        
    // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // go to posts child node then to child uid
        let usersBoysListNode = Database.database().reference().child("NasiBoysList").child(uid)
        
        
        //let selectedBoyImageURLRef = usersBoysListNode.child("boyProfileImageURLString")
        
            self.dismiss(animated: true, completion: nil)
        }
    
    
    
    }
    



