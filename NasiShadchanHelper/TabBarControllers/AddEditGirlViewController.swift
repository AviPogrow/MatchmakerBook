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
    
    enum ProfileFormTag: String {
        case age
        case dateOfBirth
    }
    //MARK: DidScanAndParse
    func didScanAndParseResume(dict: [String: String]) {
        let firstName = dict["firstName"]
        let lastName = dict["lastName"]
        let phoneNumber = dict["telephone"]
        let city = dict["city"]
        let dob = dict["dob"]
        let height = dict["height"]
        let heightInInches = dict["heightInInches"] ?? ""
        
        // get a reference to the date of birth row
        let dobRow: DateRow? = form.rowBy(tag: "dob") as? DateRow
        // if it is not nil
        if let dobRow = dobRow {
            let dobString = dob ?? ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YY/MM/dd"
            let dateOfBirth: Date! = dateFormatter.date(from: dobString)
            dobRow.value  = dateOfBirth
            dobRow.updateCell()
            let birthday = dobRow.value!
            let ageDouble = calculateAgeFrom(dob: birthday)
            let ageInt = Int(ageDouble)
            var ageTag = tagForGirlAge(ageInt)
            let ageString = "\(ageDouble)"
            
            
            // get reference to the age row and update
            let ageRow: PhoneRow? = form.rowBy(tag: "age") as? PhoneRow
            if let ageRow = ageRow {
                ageRow.value = ageString
                ageRow.cell.layer.borderColor = UIColor.systemBlue.cgColor
                ageRow.updateCell()
            }
            //let ageEntered = Int(row.value ?? "0") ?? 0
         let tagRow: LabelRow? = form.rowBy(tag: "ageTagRow")  as? LabelRow
            if let tagRow = tagRow {
           tagRow.value = ageTag
            tagRow.hidden = false
            tagRow.updateCell()
            }
        }
        
    if let heightRow = form.rowBy(tag: "height") as? ActionSheetRow<String>,
           let height = dict["height"] {
            heightRow.value = height          // must match one of the options strings
            heightRow.updateCell()
        }
        
        let firstNameRow: TextRow? = form.rowBy(tag: "firstName") as? TextRow
        if let firstNameRow = firstNameRow {
        firstNameRow.value = firstName
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
    func tagForGirlAge(_ age: Int) -> String {
        switch age {
        case 19...23:
            return "19-23"
        case 24...28:
            return "24-28"
        case 29...:
            return "29+"
        default:
            return "Unknown"
        }
    }
    
    var ageRowChangingDateRow: Bool = false
    
    var selectedShadchanGirl: ShadchanGirl!
    var isEditingGirl = true
    
    let initialHeight = Float(200.0)
    var notesImageView: UIImageView!
    var resumeImageView: UIImageView!
    var girlsPhotoImageView: UIImageView!
    var activeImageView = 1
    
    var datingHistory: String = ""
    var scanResumeButton: UIButton!
    
    var isSyncingDOBAndAge = false
    
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
        
        
        //MARK: Girls Name
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
            <<< makeAgeRow()

        form +++ Section()
            <<< makeDOBRow()

        
         //MARK: Height
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
                let selected = row.value ?? "N/A"
                self.selectedShadchanGirl?.girlHeight = selected
                
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
        
        
         let lifePlanSection = SelectableSection<ImageCheckRow<String>>(
             "Life Plans - Check All That Apply",
             selectionType: .multipleSelection
         )
        
         lifePlanSection.tag = "lifePlansSection"
         form +++ lifePlanSection
        
        let lifePlanOptions = LifePlanTag.allCases.map(\.title)

        /*
        let lifePlanOptions = [
            "FTL - 1-3",
            "FTL - 3-5",
            "FTL - 5",
            "FTL - 5-7",
            "FTL - 7+",
            "PTL - School",
            "PTL - Working",
            "FTW/College-Yeshiva Style",
            "FTW/College-Not Yeshiva Style"
        ]
         */

         for option in lifePlanOptions {
             lifePlanSection <<< ImageCheckRow<String>() { row in
                 row.title = option
                 row.selectableValue = option

                 let selectedPlans = selectedShadchanGirl.lifePlans
                 row.value = selectedPlans.contains(option) ? option : nil
             }
             .cellSetup { cell, _ in
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
        }
    // MARK: - DOB <-> Age Sync (drop-in)
    // Put these inside AddEditGirlViewController

    private let dobFormat = "YY/MM/dd" // keep for now

    private func makeDateFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = dobFormat
        return df
    }

    private func applyDOB(_ date: Date) {
        if isSyncingDOBAndAge { return }
        isSyncingDOBAndAge = true
        defer { isSyncingDOBAndAge = false }

        // model
        let df = makeDateFormatter()
        selectedShadchanGirl.dobIntervalString = df.string(from: date)

        // DOB row UI
        if let dobRow = form.rowBy(tag: "dob") as? DateRow {
            dobRow.value = date
            dobRow.updateCell()
        }

        // Age row UI
        let ageDouble = calculateAgeFrom(dob: date)
        if let ageRow = form.rowBy(tag: "age") as? IntRow {
            ageRow.value = Int(ageDouble.rounded(.down))
            ageRow.updateCell()
        }
    }

    private func applyAge(_ ageEntered: Int) {
        if isSyncingDOBAndAge { return }
        isSyncingDOBAndAge = true
        defer { isSyncingDOBAndAge = false }

        let dob = dobByAddingYears(numberOfYears: ageEntered)

        // model
        let df = makeDateFormatter()
        selectedShadchanGirl.dobIntervalString = df.string(from: dob)

        // DOB row UI
        if let dobRow = form.rowBy(tag: "dob") as? DateRow {
            dobRow.value = dob
            dobRow.updateCell()
        }

        // Age row UI (optional: keep what user typed, but updating is fine)
        if let ageRow = form.rowBy(tag: "age") as? IntRow {
            ageRow.value = ageEntered
            ageRow.updateCell()
        }
    }

    // MARK: - Age Row (IntRow)
    private func makeAgeRow() -> IntRow {
        return IntRow() { row in
            row.tag = "age"
            row.title = "Age"
            row.placeholder = "Enter Girls Age"

            // initial value from model DOB string
            let dobString = selectedShadchanGirl.dobIntervalString
            let girlAgeDouble = selectedShadchanGirl.calculateAgeFrom(dobString: dobString)
            let girlAgeInt = Int(girlAgeDouble.rounded(.down))
            row.value = (girlAgeInt > 0) ? girlAgeInt : nil

            row.onChange { [unowned self] row in
                if self.isSyncingDOBAndAge { return }
                guard let age = row.value, age > 0 else { return }
                self.applyAge(age)
            }
        }
    }

    // MARK: - DOB Row
    private func makeDOBRow() -> DateRow {
        return DateRow() { row in
            row.tag = "dob"
            row.title = "Date of Birth"
            row.maximumDate = Date()

            let df = makeDateFormatter()
            let dobString = selectedShadchanGirl.dobIntervalString
            row.value = df.date(from: dobString) // nil is fine; row will show empty

            row.onChange { [unowned self] row in
                if self.isSyncingDOBAndAge { return }
                guard let date = row.value else { return }
                self.applyDOB(date)
            }
        }
    }

    
   
    
    func heightTag(from heightString: String) -> String? {
        
        let clean = heightString
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "”", with: "\"")
            .replacingOccurrences(of: "“", with: "\"")
        
        let pattern = #"(\d)'\s*(\d{1,2})"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: clean, range: NSRange(clean.startIndex..., in: clean)),
              let feetRange = Range(match.range(at: 1), in: clean),
              
                let inchRange = Range(match.range(at: 2), in: clean) else {return nil}
        
        let feet = Int(clean[feetRange]) ?? 0
        let inches = Int(clean[inchRange]) ?? 0
        let totalInches = feet * 12 + inches
        
        
    
    switch totalInches {
    case 0..<60:   return "Under 5'0\""
    case 60...61: return "5'0\" - 5'2\""
    case 62...65: return "5'2\" - 5'5\""
    case 66...68:   return "5'6\" - 5'8\'"
    case 68...100:    return "5'9+\""
    default:      return nil
        
    }
}
    func colorForHeightTag(_ tag: String) -> UIColor {
        switch tag {
        case "Under 5'0":
            return UIColor.systemPink   // or whatever you want
        case "5'0–5'2":
            return UIColor.systemOrange
        case "5'2–5'5":
            return UIColor.systemYellow
        case "5'6–5'8":
            return UIColor.systemGreen
        case "5'9+":
            return UIColor.systemBlue
        default:
            return UIColor.systemGray
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
        super.valueHasBeenChanged(for: row, oldValue: oldValue, newValue: newValue)

        guard row.section?.tag == "lifePlansSection",
              let selectable = row.section as? SelectableSection<ImageCheckRow<String>>
        else { return }

        let values: [String] = selectable
            .selectedRows()
            .compactMap { $0.value }   // no force unwrap

        selectedShadchanGirl.lifePlans = values
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
    
    
        self.selectedShadchanGirl =
        ShadchanGirl(girlCell: "",
        girlLastName: "",
        girlFirstName: "",
        city: "",
        dobIntervalString: "",
        dateCreated: dateCreatedString,
        dateLastUpdate: updateTimeStamp,
        girlHeight: "",
        sendResumeEmail: "",
        sendResumeText: "",
        lifePlans:[],
        status: "available",
        datingHistory:"",
        shadchanNotesNew: "",
        notesImageURL: "",
        resumeImageURL: "",
        photoImageURL: "")
       
    }
    
    @objc func saveGirlToFirebase() {
        if isEditingGirl {
            selectedShadchanGirl.dateLastUpdate = Int(Date().timeIntervalSince1970)
        }

        saveSelectedShadchanGirlToFB { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                self.navigationController?.popToRootViewController(animated: true)

            case .failure(let error):
                // TODO: show alert / toast / HUD
                print("Save failed:", error)
            }
        }
    }

    func saveSelectedShadchanGirlToFB(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let dict = selectedShadchanGirl.toDictionary()

        if let existingRef = selectedShadchanGirl.ref {
            // Safer for editing: doesn't wipe fields not included in dict (as long as dict is partial or correct)
            existingRef.updateChildValues(dict) { error, _ in
                if let error { completion(.failure(error)) }
                else { completion(.success(())) }
            }
        } else {
            let baseRef = Database.database().reference()
                .child("PrivateGirlsList")
                .child(uid)

            let newRef = baseRef.childByAutoId()
            selectedShadchanGirl.ref = newRef
            selectedShadchanGirl.key = newRef.key ?? ""

            newRef.setValue(dict) { error, _ in
                if let error { completion(.failure(error)) }
                else { completion(.success(())) }
            }
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
        
            self.dismiss(animated: true, completion: nil)
        }
    }
    



