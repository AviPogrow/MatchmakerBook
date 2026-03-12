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

class AddEditGirlViewController: FormViewController, CNContactPickerDelegate, ResumeScanVCDelegate, GirlDraftProvider, NavigationStateProvider {
    
    enum ProfileFormTag: String {
        case age
        case dateOfBirth
    }
    
    
     // MARK: - DidScanAndParse (ISO version)
     func didScanAndParseResume(dict: [String: String]) {

         // 0) Clean inputs
         func clean(_ key: String) -> String {
             (dict[key] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
         }

         let firstName = clean("firstName")
         let lastName  = clean("lastName")
         let phone     = clean("telephone")
         let city      = clean("city")
         let height    = clean("height")
         let rawDOB    = clean("dob")

         // -------------------------
         // 1) UPDATE MODEL
         // -------------------------
         if !firstName.isEmpty { selectedShadchanGirl.girlFirstName = firstName }
         if !lastName.isEmpty  { selectedShadchanGirl.girlLastName  = lastName }
         if !phone.isEmpty     { selectedShadchanGirl.girlCell      = phone }
         if !city.isEmpty      { selectedShadchanGirl.city          = city }
         if !height.isEmpty    { selectedShadchanGirl.girlHeight    = height }

         // -------------------------
         // 2) UPDATE UI (Eureka rows)
         // -------------------------
         if let r = form.rowBy(tag: "firstName") as? TextRow, !firstName.isEmpty {
             r.value = firstName
             r.updateCell()
         }

         if let r = form.rowBy(tag: "lastName") as? TextRow, !lastName.isEmpty {
             r.value = lastName
             r.updateCell()
         }

         if let r = form.rowBy(tag: "cell") as? PhoneRow, !phone.isEmpty {
             r.value = phone
             r.updateCell()
         }

         if let r = form.rowBy(tag: "city") as? TextRow, !city.isEmpty {
             r.value = city
             r.updateCell()
         }

         if let r = form.rowBy(tag: "height") as? ActionSheetRow<String>, !height.isEmpty {
             r.value = height
             r.updateCell()
         }

         // -------------------------
         // 3) DOB -> ISO normalize -> applyDOB (handles DOB row + Age row)
         // -------------------------
         if !rawDOB.isEmpty,
            let iso = ISODateOnly.normalizeToISO(rawDOB),
            let dobDate = ISODateOnly.dateForDateRow(fromISO: iso) {

             // self-heal model immediately
             selectedShadchanGirl.dobIntervalString = iso

             // applyDOB will:
             // - store ISO in model (again, ok)
             // - set DateRow value safely
             // - update Age IntRow
             applyDOB(dobDate)

             // Optional: update age tag row (if you use it)
             let ageYears = calculateAgeYears(fromDOBISO: iso)
             let ageTag = tagForGirlAge(ageYears)
             if let tagRow = form.rowBy(tag: "ageTagRow") as? LabelRow {
                 tagRow.value = ageTag
                 tagRow.hidden = false
                 tagRow.updateCell()
             }
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
        
        
        
        
        if isEditingGirl {
            navigationItem.title = "Edit Profile"
            let barButtonDelete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteTapped))
            barButtonDelete.tintColor = UIColor.red
            
            let barButtonSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveGirlToFirebase))
            
            navigationItem.rightBarButtonItems = [barButtonSave, barButtonDelete]
            
            
        }
        else {
            navigationItem.title = "Add Profile Details"
            //showAddGirlOptions()
            initNewNasiGirl()
            
            let barButtonSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveGirlToFirebase))
            navigationItem.rightBarButtonItem = barButtonSave
        }
        
        self.tableView.backgroundColor = UIColor.white
        
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
            $0.tag = "sendResumeText"
            $0.placeholder = "Cell"
            
            $0.value = selectedShadchanGirl?.sendResumeText  //5
            
            $0.onChange { [unowned self] row in //6
                self.selectedShadchanGirl?.sendResumeText = row.value ?? ""
            }
        }
        
        +++ Section("Shadchan Notes")
        
        <<< TextAreaRow() {
            $0.tag = "shadchanNotesNew"
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DraftManager.shared.activeDraftProvider = self
        NavigationStateManager.shared.activeProvider = self

        //if let draft = DraftManager.shared.loadDraft() {
        //    applyDraft(draft)
       // }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if DraftManager.shared.activeDraftProvider === self {
            DraftManager.shared.activeDraftProvider = nil
        }

        if NavigationStateManager.shared.activeProvider === self {
            NavigationStateManager.shared.activeProvider = nil
        }
    }
    
    
    // MARK: - DOB <-> Age Sync (drop-in)
    // Put these inside AddEditGirlViewController
    private func applyDOB(_ date: Date) {
         if isSyncingDOBAndAge { return }
         isSyncingDOBAndAge = true
         defer { isSyncingDOBAndAge = false }

         // model (store ISO)
         let iso = ISODateOnly.iso(from: date)
         selectedShadchanGirl.dobIntervalString = iso

         // DOB row UI (noon-local)
         if let dobRow = form.rowBy(tag: "dob") as? DateRow {
             dobRow.value = ISODateOnly.dateForDateRow(fromISO: iso)
             dobRow.updateCell()
         }

         // Age row UI
         let ageYears = calculateAgeYears(fromDOBISO: iso)
         if let ageRow = form.rowBy(tag: "age") as? IntRow {
             ageRow.value = (ageYears > 0) ? ageYears : nil
             ageRow.updateCell()
         }
     }
     
    func calculateAgeYears(fromDOBISO iso: String) -> Int {
        guard let date = ISODateOnly.dateForDateRow(fromISO: iso) else { return 0 }
        let cal = Calendar.current
        let today = Date()
        let years = cal.dateComponents([.year], from: date, to: today).year ?? 0
        return max(years, 0)
    }
    
  

    private func applyAge(_ ageEntered: Int) {
        if isSyncingDOBAndAge { return }
        isSyncingDOBAndAge = true
        defer { isSyncingDOBAndAge = false }

        let dob = dobByAddingYears(numberOfYears: ageEntered)
        let iso = ISODateOnly.iso(from: dob)
        selectedShadchanGirl.dobIntervalString = iso

        if let dobRow = form.rowBy(tag: "dob") as? DateRow {
            dobRow.value = ISODateOnly.dateForDateRow(fromISO: iso)
            dobRow.updateCell()
        }

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
        row.placeholder = "Enter Girl's Age"

        // Initial value from model DOB string (backward compatible)
        let rawDOB = selectedShadchanGirl.dobIntervalString
        if let iso = ISODateOnly.normalizeToISO(rawDOB) {
            // self-heal in-memory (optional but recommended)
            if iso != rawDOB {
                selectedShadchanGirl.dobIntervalString = iso
            }

            let ageYears = calculateAgeYears(fromDOBISO: iso)
            row.value = (ageYears > 0) ? ageYears : nil
        } else {
            row.value = nil
        }

        row.onChange { [unowned self] row in
            if self.isSyncingDOBAndAge { return }
            guard let age = row.value, age > 0 else { return }
            self.applyAge(age)
        }
    }
}
    
    // MARK: - DOB Row
    
    private func makeDOBRow() -> DateRow {
        DateRow() { row in
            row.tag = "dob"
            row.title = "Date of Birth"
            row.maximumDate = Date()

            if let iso = ISODateOnly.normalizeToISO(selectedShadchanGirl.dobIntervalString),
               let date = ISODateOnly.dateForDateRow(fromISO: iso) {

                // optional: self-heal model if it was legacy
                selectedShadchanGirl.dobIntervalString = iso
                row.value = date
            } else {
                row.value = nil
            }

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
        //alert.addAction(UIAlertAction(title: "Add Manually", style: .default, handler: { (_) in
        //  self.handleAddManually()
        //}))
        
        alert.addAction(UIAlertAction(title: "Import From Contacts", style: .default, handler: { (_) in
            self.importFromContacts()
        }))
        alert.addAction(UIAlertAction(title: "Scan Resume", style: .default, handler: { (_) in
            self.handleScanResumeWithDocScanner()
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert,animated: true)
    }
    
    
   
    
    @objc func handleScanResumeWithDocScanner() {
        
    let scanVC = ResumeScanVC()
    scanVC.delegate = self
    navigationController?.pushViewController(scanVC, animated: true)
   }
    
    func dobByAddingYears(numberOfYears age: Int) -> Date {
        let cal = Calendar.current
        let currentYear = cal.component(.year, from: Date())

        var comps = DateComponents()
        comps.year = currentYear - age
        comps.month = 1
        comps.day = 1
        comps.hour = 12

        return cal.date(from: comps)!
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

    func initNewNasiGirl() {
        let now = Date()
        let updateTimeStamp = Int(now.timeIntervalSince1970)

        let dateCreatedISO = ISODateOnly.iso(from: now) // "yyyy-MM-dd"

        self.selectedShadchanGirl = ShadchanGirl(
            girlCell: "",
            girlLastName: "",
            girlFirstName: "",
            city: "",
            dobIntervalString: "",          // ISO when set
            dateCreated: dateCreatedISO,    // ✅ was "YY/MM/dd"
            dateLastUpdate: updateTimeStamp,
            girlHeight: "",
            sendResumeEmail: "",
            sendResumeText: "",
            lifePlans: [],
            status: "available",
            datingHistory: "",
            shadchanNotesNew: "",
            notesImageURL: "",
            resumeImageURL: "",
            photoImageURL: ""
        )
    }
    
    func applyDraft(_ draft: GirlDraft) {
        selectedShadchanGirl.girlFirstName = draft.girlFirstName
        selectedShadchanGirl.girlLastName = draft.girlLastName
        selectedShadchanGirl.girlCell = draft.girlCell
        selectedShadchanGirl.city = draft.city
        selectedShadchanGirl.dobIntervalString = draft.dobIntervalString
        selectedShadchanGirl.girlHeight = draft.girlHeight
        selectedShadchanGirl.lifePlans = draft.lifePlans
        selectedShadchanGirl.sendResumeEmail = draft.sendResumeEmail
        selectedShadchanGirl.sendResumeText = draft.sendResumeText
        selectedShadchanGirl.shadchanNotesNew = draft.shadchanNotesNew
        isEditingGirl = draft.isEditingGirl

        if let key = draft.girlKey {
            selectedShadchanGirl.key = key
        }

        if let row = form.rowBy(tag: "firstName") as? TextRow {
            row.value = draft.girlFirstName
            row.updateCell()
        }

        if let row = form.rowBy(tag: "lastName") as? TextRow {
            row.value = draft.girlLastName
            row.updateCell()
        }

        if let row = form.rowBy(tag: "cell") as? PhoneRow {
            row.value = draft.girlCell
            row.updateCell()
        }

        if let row = form.rowBy(tag: "city") as? TextRow {
            row.value = draft.city
            row.updateCell()
        }

        if let row = form.rowBy(tag: "height") as? ActionSheetRow<String> {
            row.value = draft.girlHeight
            row.updateCell()
        }

        if let row = form.rowBy(tag: "email") as? TextRow {
            row.value = draft.sendResumeEmail
            row.updateCell()
        }

        if let row = form.rowBy(tag: "sendResumeText") as? PhoneRow {
            row.value = draft.sendResumeText
            row.updateCell()
        }

        if let row = form.rowBy(tag: "shadchanNotesNew") as? TextAreaRow {
            row.value = draft.shadchanNotesNew
            row.updateCell()
        }

        if let iso = ISODateOnly.normalizeToISO(draft.dobIntervalString),
           let date = ISODateOnly.dateForDateRow(fromISO: iso) {
            applyDOB(date)
        }

        if let section = form.sectionBy(tag: "lifePlansSection") as? SelectableSection<ImageCheckRow<String>> {
            for baseRow in section.allRows {
                guard let row = baseRow as? ImageCheckRow<String>,
                      let value = row.selectableValue else { continue }

                row.value = draft.lifePlans.contains(value) ? value : nil
                row.updateCell()
            }
        }
    }
    func makeDraft() -> GirlDraft {
        GirlDraft(
            girlFirstName: selectedShadchanGirl.girlFirstName,
            girlLastName: selectedShadchanGirl.girlLastName,
            girlCell: selectedShadchanGirl.girlCell,
            city: selectedShadchanGirl.city,
            dobIntervalString: selectedShadchanGirl.dobIntervalString,
            girlHeight: selectedShadchanGirl.girlHeight,
            lifePlans: selectedShadchanGirl.lifePlans,
            sendResumeEmail: selectedShadchanGirl.sendResumeEmail,
            sendResumeText: selectedShadchanGirl.sendResumeText,
            shadchanNotesNew: selectedShadchanGirl.shadchanNotesNew,
            isEditingGirl: isEditingGirl,
            girlKey: selectedShadchanGirl.key
        )
    }
    func makeNavigationState() -> NavigationState {
        NavigationState(
            screenID: "addEditGirl",
            isEditingGirl: isEditingGirl,
            girlKey: selectedShadchanGirl.key.isEmpty ? nil : selectedShadchanGirl.key
        )
    }
    @objc func saveGirlToFirebase() {

        
        selectedShadchanGirl.dateLastUpdate = Int(Date().timeIntervalSince1970)
        

        saveSelectedShadchanGirlToFB { [weak self] result in
            guard let self else { return }

            switch result {

            case .success:
                
                DraftManager.shared.clearDraft()
                NavigationStateManager.shared.clear()

                if self.presentingViewController != nil {
                    self.dismiss(animated: true)
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }

            case .failure(let error):
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

    

  
    @objc private func deleteTapped() {
        let name = "\(selectedShadchanGirl.girlFirstName) \(selectedShadchanGirl.girlLastName)"
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let message = name.isEmpty
            ? "This will permanently remove this record. This action cannot be undone."
            : "This will permanently delete \(name). This action cannot be undone."

        let alert = UIAlertController(
            title: "Delete Girl?",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete()
        })

        present(alert, animated: true)
    }
    
    private func performDelete() {
        guard isEditingGirl else { return }

        // Best case: you have a ref from the snapshot
        if let ref = selectedShadchanGirl.ref {
            ref.removeValue { [weak self] error, _ in
                guard let self else { return }
                if let error {
                    self.presentDeleteError(error)
                    return
                }
                self.navigationController?.popToRootViewController(animated: true)
            }
            return
        }

        // Fallback: build the ref from uid + key
        guard let uid = Auth.auth().currentUser?.uid, !selectedShadchanGirl.key.isEmpty else { return }

        let ref = Database.database().reference()
            .child("PrivateGirlsList")
            .child(uid)
            .child(selectedShadchanGirl.key)

        ref.removeValue { [weak self] error, _ in
            guard let self else { return }
            if let error {
                self.presentDeleteError(error)
                return
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    private func presentDeleteError(_ error: Error) {
        let alert = UIAlertController(
            title: "Couldn’t Delete",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
    



