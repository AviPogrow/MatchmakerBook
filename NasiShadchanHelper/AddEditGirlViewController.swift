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
import Combine

class AddEditGirlViewController: FormViewController, CNContactPickerDelegate, ResumeScanVCDelegate, GirlDraftProvider, NavigationStateProvider {
    
    //MARK: Age row and Dob row sync
    var ageRowChangingDateRow: Bool = false
    var isSyncingDOBAndAge = false

    //MARK:  Data Model
    var selectedShadchanGirl: ShadchanGirl!
    var isEditingGirl = true

    //MARK:  ImageView Handlers
    let initialHeight = Float(200.0)
    var notesImageView: UIImageView!
    var resumeImageView: UIImageView!
    var girlsPhotoImageView: UIImageView!
    var activeImageView = 1
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?

    
    var datingHistory: String = ""
    var scanResumeButton: UIButton!

    
    
    // MARK: - Debounced Autosave
    private let draftDidChangeSubject = PassthroughSubject<Void, Never>()

    /// Stores Combine subscriptions so they stay alive
    /// for as long as this view controller is alive.
    private var cancellables = Set<AnyCancellable>()
    private var isRestoringFormState = false
    

    enum ProfileFormTag: String {
        case age
        case dateOfBirth
    }
     
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Start listening for debounced autosave events
        setupDebouncedAutosave()
        configureScreenMode()
        configureTableView()
        buildForm()
    }
    
    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
        super.valueHasBeenChanged(for: row, oldValue: oldValue, newValue: newValue)

        guard row.section?.tag == "lifePlansSection",
              let selectable = row.section as? SelectableSection<ImageCheckRow<String>>
        else { return }

        let values: [String] = selectable
            .selectedRows()
            .compactMap { $0.value }

        selectedShadchanGirl.lifePlans = values

        // Notify autosave pipeline
        notifyDraftDidChange()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DraftManager.shared.activeDraftProvider = self
        NavigationStateManager.shared.activeProvider = self
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
}

//MARK: Data Model
extension AddEditGirlViewController {
    
    func initNewNasiGirl() {
        let now = Date()
        let updateTimeStamp = Int(now.timeIntervalSince1970)
        let dateCreatedISO = ISODateOnly.iso(from: now)

        self.selectedShadchanGirl = ShadchanGirl(
            girlCell: "",
            girlLastName: "",
            girlFirstName: "",
            city: "",
            dobIntervalString: "",
            dateCreated: dateCreatedISO,
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
}

//MARK:  Firebase Persistence
extension AddEditGirlViewController {
    func uploadImageAndGetURLAndSetInstanceVar(image: UIImage, identifier: String) {
        self.view.showLoadingIndicator()

        print("upload image invoked - image state is \(image)")
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

   
    private func presentDeleteError(_ error: Error) {
        let alert = UIAlertController(
            title: "Couldn’t Delete",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

   

    private func performDelete() {
        guard isEditingGirl else { return }

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
}
extension AddEditGirlViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Image Helper Methods
    
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

        let pinchGesture = UIPinchGestureRecognizer()
        zoomingImageView.addGestureRecognizer(pinchGesture)

        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)

            keyWindow.addSubview(zoomingImageView)

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1

                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: { _ in
                // do nothing
            })
        }
    }

    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
            }, completion: { _ in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }

    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            self.performZoomInForStartingImageView(imageView)
        }
    }
    
    @objc func pickPhoto(_ tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            print("the imageView is \(imageView.debugDescription)")
            if imageView.tag == 103 {
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
        ppc?.permittedArrowDirections = .any
        present(imagePicker, animated: true)
    }

    // MARK: - Image Picker Delegates
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if let theImage = image {

            print("value of active image View is \(activeImageView)")

            var identifier = ""
            if activeImageView == 3 {
                self.girlsPhotoImageView.image = theImage
                identifier = "photoImageURL"
            } else if activeImageView == 2 {
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

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func showPhotoMenu() {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        let actCancel = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        alert.addAction(actCancel)

        let actPhoto = UIAlertAction(
            title: "Take Photo",
            style: .default
        ) { _ in
            self.takePhotoWithCamera()
        }
        alert.addAction(actPhoto)

        let actLibrary = UIAlertAction(
            title: "Choose From Library",
            style: .default
        ) { _ in
            self.choosePhotoFromLibrary()
        }
        alert.addAction(actLibrary)

        if let popView = alert.popoverPresentationController {
            popView.sourceView = self.girlsPhotoImageView
            popView.sourceRect = self.girlsPhotoImageView.frame
            present(alert, animated: true, completion: nil)
        } else {
            present(alert, animated: true)
        }
    }

    func show(image: UIImage) {
        // placeholder
    }

   
}
extension AddEditGirlViewController {
    
    
    // MARK: - Autosave
    
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
    private func notifyDraftDidChange() {
        
        // Ignore change notifications while we are restoring/applying data
        // to avoid accidental autosaves caused by programmatic row updates.
        guard !isRestoringFormState else { return }
        
        draftDidChangeSubject.send(())
    }
    
    
    
    private func setupDebouncedAutosave() {
        draftDidChangeSubject
        // Wait 800ms after the most recent change before emitting an event.
        // If the user keeps typing, the timer resets.
            .debounce(for: .milliseconds(800), scheduler: RunLoop.main)
        
        // When the debounce fires, perform the autosave.
            .sink { [weak self] in
                self?.saveDraftFromCurrentFormState()
            }
        
        // Store the subscription so it stays alive
            .store(in: &cancellables)
    }
    
    
    
    /// Called by the Combine debounce pipeline when the user
    /// has paused editing the form for a short period.
    ///
    /// This method:
    /// 1. Builds a GirlDraft from the current form state
    /// 2. Asks DraftManager to persist it
    ///
    /// Important:
    /// We intentionally build the draft *here* rather than inside
    /// the row handlers so that:
    /// - row handlers stay lightweight
    /// - there is a single place responsible for draft creation
    private func saveDraftFromCurrentFormState() {
        
        // Build a draft using the existing source of truth for draft creation
        let draft = makeDraft()
        
        // Persist the draft using the centralized DraftManager
        DraftManager.shared.saveDraft(draft)
        
        // Helpful for development to confirm debounce behavior
        print("💾 Debounced autosave triggered")
    }
}

extension AddEditGirlViewController {
    //MARK:  Import from Contacts
    func importFromContacts() {
        let store = CNContactStore()
        switch CNContactStore.authorizationStatus(for: .contacts) {

        case .authorized:
            self.presentContactPicker()

        case .notDetermined:
            store.requestAccess(for: .contacts) { (granted, error) in
                if granted {
                    self.presentContactPicker()
                } else {
                    self.showAccessDeniedAlert()
                }
            }

        default:
            self.showAccessDeniedAlert()
        }
    }

    func showAccessDeniedAlert() {
        let alert = UIAlertController(title: "Contacts Access Denied", message: "Please enable contacts access in settings in Settings to import contacts.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        present(alert, animated: true)
    }

}


extension AddEditGirlViewController {
    // MARK: - External Data Application
    
    @objc func handleScanResumeWithDocScanner() {
        let scanVC = ResumeScanVC()
        scanVC.delegate = self
        navigationController?.pushViewController(scanVC, animated: true)
    }

    @objc func showAddGirlOptions() {
        let alert = UIAlertController(title: "Add Girl", message: "Choose how you'd like to add a girl", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Import From Contacts", style: .default, handler: { (_) in
            self.importFromContacts()
        }))

        alert.addAction(UIAlertAction(title: "Scan Resume", style: .default, handler: { (_) in
            self.handleScanResumeWithDocScanner()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func performProgrammaticFormUpdate(_ updates: () -> Void) {
        
       isRestoringFormState = true
        
        // Run all model + UI updates
        updates()
        
        // Re-enable normal autosave behavior after the updates finish.
        isRestoringFormState = false
    }


     func didScanAndParseResume(dict: [String: String]) {

       
         func clean(_ key: String) -> String {
             (dict[key] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
         }

         let firstName = clean("firstName")
         let lastName  = clean("lastName")
         let phone     = clean("telephone")
         let city      = clean("city")
         let height    = clean("height")
         let rawDOB    = clean("dob")

         // Resume scanning is a programmatic form update, not manual typing.
         // Temporarily disable row-triggered autosave while we apply parsed values.
         performProgrammaticFormUpdate {

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

                 // Self-heal model immediately
                 selectedShadchanGirl.dobIntervalString = iso

                 // applyDOB will:
                 // - store ISO in model
                 // - set DateRow value safely
                 // - update Age IntRow
                 applyDOB(dobDate)

                 // Optional: update age tag row (if you use it)
                 let ageYears = calculateAgeYears(fromDOBISO: iso)
                 //let ageTag = tagForGirlAge(ageYears)
                 //if let tagRow = form.rowBy(tag: "ageTagRow") as? LabelRow {
                 //    tagRow.value = ageTag
                 //    tagRow.hidden = false
                 //    tagRow.updateCell()
             //    }
             }
         }

         // Now that all parsed values are fully applied, emit one change event.
         // This produces one debounced autosave instead of multiple row-triggered saves.
         notifyDraftDidChange()
     }
    
    
    func importContact(_ contact: CNContact) {
        
        let firstName = "\(contact.givenName)"
        let lastName = "\(contact.familyName)"
        let phoneNumbers = contact.phoneNumbers.map({ $0.value as CNPhoneNumber })
        let cellNumber = "\(phoneNumbers.first?.stringValue ?? "")"
        let emails = contact.emailAddresses.map({ $0.value as String })
        let email = "\(emails.first ?? "")"
        
        let address = contact.postalAddresses.first?.value as CNPostalAddress?
        let city = "\(address?.city ?? "Not Found")"
        
        let height = "\(contact.note ?? "No Note")"
        
        print("imported contact: \(firstName), \(phoneNumbers), \(emails)")
        print("email: \(email), height note: \(height)")
        
        // Contact import is a programmatic form update, not manual typing.
        // Temporarily disable row-triggered autosave while we apply values.
        performProgrammaticFormUpdate {
            
            selectedShadchanGirl.girlFirstName = firstName
            selectedShadchanGirl.girlLastName = lastName
            selectedShadchanGirl.girlCell = cellNumber
            selectedShadchanGirl.city = city
            
            // Optional: only map these if you really want contact data to populate them
            // selectedShadchanGirl.sendResumeEmail = email
            // selectedShadchanGirl.girlHeight = height
            
            // Update visible rows
            
            if let firstNameRow = form.rowBy(tag: "firstName") as? TextRow {
                firstNameRow.value = firstName
                firstNameRow.updateCell()
            }
            
            if let secondNameRow = form.rowBy(tag: "lastName") as? TextRow {
                secondNameRow.value = lastName
                secondNameRow.updateCell()
            }
            
            if let cellRow = form.rowBy(tag: "cell") as? PhoneRow {
                cellRow.value = cellNumber
                cellRow.updateCell()
            }
            
            if let cityRow = form.rowBy(tag: "city") as? TextRow {
                cityRow.value = city
                cityRow.updateCell()
            }
            
            // If you later decide to import email into the form:
            /*
            if let emailRow = form.rowBy(tag: "email") as? TextRow {
                emailRow.value = email
                emailRow.updateCell()
            }
            */
            
            // If you later decide to map contact.note into height:
            /*
            if let heightRow = form.rowBy(tag: "height") as? ActionSheetRow<String> {
                heightRow.value = height
                heightRow.updateCell()
            }
            */
        }
        
        // Now that the import is fully applied, emit one change event.
        // This results in a single debounced autosave instead of many row-triggered saves.
        notifyDraftDidChange()
    }

    func applyDraft(_ draft: GirlDraft) {
        
        // Draft restoration is a programmatic form update, not a user edit.
        // We temporarily disable row-triggered autosave while restoring.
        performProgrammaticFormUpdate {
            
            // Update the working model first
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

            // Update visible form rows to match the restored model
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

            // Restore DOB and age in a synchronized way
            if let iso = ISODateOnly.normalizeToISO(draft.dobIntervalString),
               let date = ISODateOnly.dateForDateRow(fromISO: iso) {
                applyDOB(date)
            }

            // Restore life plan selections
            if let section = form.sectionBy(tag: "lifePlansSection") as? SelectableSection<ImageCheckRow<String>> {
                for baseRow in section.allRows {
                    guard let row = baseRow as? ImageCheckRow<String>,
                          let value = row.selectableValue else { continue }

                    row.value = draft.lifePlans.contains(value) ? value : nil
                    row.updateCell()
                }
            }
        }
    }
    
}
extension AddEditGirlViewController {
    // MARK: - DOB <-> Age Sync
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

}

extension AddEditGirlViewController {
    //MARK: State Restoration
    func makeNavigationState() -> NavigationState {
        // Capture the currently selected tab so restoration pushes
        // AddEditGirlViewController onto the correct navigation controller.
        let tabIndex = tabBarController?.selectedIndex ?? 0

        return NavigationState(
            screenID: "addEditGirl",
            isEditingGirl: isEditingGirl,

            // Avoid storing an empty string as if it were a real key.
            girlKey: selectedShadchanGirl.key.isEmpty ? nil : selectedShadchanGirl.key,

            tabIndex: tabIndex
        )
    }
    
}

// MARK: - CNContactPickerDelegate
extension AddEditGirlViewController {
    func presentContactPicker() {
        let contactPickerVC = CNContactPickerViewController()

        contactPickerVC.delegate = self
        contactPickerVC.displayedPropertyKeys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
        ]

        present(contactPickerVC, animated: true)
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        importContact(contact)
    }

    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        dismiss(animated: true)
    }
   
}

//MARK: Setup Scene
extension AddEditGirlViewController {
    
    private func configureScreenMode(){
        if isEditingGirl {
            navigationItem.title = "Edit Profile"
            let barButtonDelete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteTapped))
            barButtonDelete.tintColor = UIColor.red

            let barButtonSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveGirlToFirebase))

            navigationItem.rightBarButtonItems = [barButtonSave, barButtonDelete]

        } else {
            navigationItem.title = "Add Profile Details"
            //showAddGirlOptions()
            initNewNasiGirl()

            let barButtonSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveGirlToFirebase))
            navigationItem.rightBarButtonItem = barButtonSave
        }
        
    }
    private func configureTableView(){
        self.tableView.backgroundColor = UIColor.white
    }
    
    private func buildForm(){
        buildCoreProfileSections()
        buildStatusAndLifePlansSections()
        buildResumeContactAndNotesSections()
        buildImageSections()
       }
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
                
                // Applying age updates the DOB-backed model and row state
                self.applyAge(age)
                
                // After the model has been updated, notify autosave
                self.notifyDraftDidChange()
            }
        }
    }
    
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

                // Applying DOB updates the model and synchronizes the Age row
                self.applyDOB(date)

                // Then notify the autosave pipeline
                self.notifyDraftDidChange()
            }
        }
    }
    private func buildCoreProfileSections() {
        
        form +++ Section("Girls Name")
        <<< TextRow() {
            $0.tag = "firstName"
            $0.placeholder = "First Name"
            $0.value = selectedShadchanGirl?.girlFirstName ?? ""
            $0.onChange { [unowned self] row in

                // Keep the in-memory working model in sync with the form
                self.selectedShadchanGirl?.girlFirstName = row.value ?? ""

                // Tell the debounced autosave pipeline that the form changed
                self.notifyDraftDidChange()
            }
        }

        <<< TextRow() {
            $0.placeholder = "Last Name"
            $0.tag = "lastName"
            $0.value = selectedShadchanGirl?.girlLastName ?? ""
            $0.onChange { [unowned self] row in

                // Update the current editing model
                self.selectedShadchanGirl?.girlLastName = row.value ?? ""

                // Trigger debounced autosave
                self.notifyDraftDidChange()
            }
        }

        form +++ Section("Girls Cell")
        <<< PhoneRow() {
            $0.title = "Cell"
            $0.tag = "cell"
            $0.placeholder = "Add numbers here"
            $0.value = self.selectedShadchanGirl?.girlCell ?? "N/A"

            $0.onChange { [unowned self] row in

                // Update the model immediately as the user edits
                self.selectedShadchanGirl?.girlCell = row.value ?? "N/A"

                // Notify the autosave pipeline
                self.notifyDraftDidChange()
            }
        }

        form +++ Section("Girls City")
        <<< TextRow() {
            $0.tag = "city"
            $0.placeholder = "City"
            $0.value = selectedShadchanGirl?.city ?? ""
            $0.onChange { [unowned self] row in

                // Keep the model synced with the text field
                self.selectedShadchanGirl?.city = row.value ?? ""

                // Trigger debounced autosave
                self.notifyDraftDidChange()
            }
        }

        form +++ Section("Girls Age")
        <<< makeAgeRow()

        form +++ Section()
        <<< makeDOBRow()

        //Height
        form
        +++
        Section()
        <<< ActionSheetRow<String>() {
            $0.tag = "height"
            $0.title = "Girls Height"
            $0.selectorTitle = "Scroll For More Options"
            $0.options = ["4'10\"","4'11\"","5'0\"","5'1\"","5'2\"","5'3\"","5'4\"","5'5\"","5'6\"","5'7\"","5'8\"","5'9\"","5'10\"","5'11\"","6'0\"","6'1\"","6'2\"","6'3\"","N/A\""]

            $0.value = self.selectedShadchanGirl?.girlHeight ?? "N/A"

            $0.onChange { [unowned self] row in

                // Update the model
                let selected = row.value ?? "N/A"
                self.selectedShadchanGirl?.girlHeight = selected

                // Trigger debounced autosave
                self.notifyDraftDidChange()
            }
        }

    }
    private func buildStatusAndLifePlansSections(){
        form
        +++
        Section()
        <<< ActionSheetRow<String>() {
            $0.title = "Girls Status"
            
            $0.selectorTitle = "Choose a Status"
            $0.options = ["available","engaged"]
            
            $0.value = self.selectedShadchanGirl?.status ?? "available"
            $0.onChange { [unowned self] row in
                
                // Update model state
                self.selectedShadchanGirl?.status = row.value ?? "available"
                
                // Trigger autosave
                self.notifyDraftDidChange()
            }
        }
        
        let lifePlanSection = SelectableSection<ImageCheckRow<String>>(
            "Life Plans - Check All That Apply",
            selectionType: .multipleSelection
        )
        
        lifePlanSection.tag = "lifePlansSection"
        form +++ lifePlanSection
        
        let lifePlanOptions = LifePlanTag.allCases.map(\.title)
        
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
    }
    
    private func buildResumeContactAndNotesSections() {
        form +++ Section("Send Resume/Contact Info")
        <<< TextRow() {
            $0.tag = "email"
            $0.placeholder = "Email"
            $0.value = selectedShadchanGirl?.sendResumeEmail

            $0.onChange { [unowned self] row in

                // Update model
                self.selectedShadchanGirl?.sendResumeEmail = row.value ?? ""

                // Notify autosave pipeline
                self.notifyDraftDidChange()
            }
        }

        <<< PhoneRow() {
            $0.tag = "sendResumeText"
            $0.placeholder = "Cell"
            $0.value = selectedShadchanGirl?.sendResumeText

            $0.onChange { [unowned self] row in

                // Update model
                self.selectedShadchanGirl?.sendResumeText = row.value ?? ""

                // Trigger autosave
                self.notifyDraftDidChange()
            }
        }

        +++ Section("Shadchan Notes")
        <<< TextAreaRow() {
            $0.tag = "shadchanNotesNew"
            $0.value = selectedShadchanGirl.shadchanNotesNew

            $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            $0.onChange { [unowned self] row in

                // Update notes in the working model
                self.selectedShadchanGirl?.shadchanNotesNew = row.value ?? ""

                // Notify autosave pipeline
                self.notifyDraftDidChange()
            }
        }

        
    }
    private func buildImageSections(){
        
        form  +++ Section("Photo of Notes")
         <<< ViewRow<UIView>()
             .cellSetup { (cell, row) in
                 cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
                 cell.view!.backgroundColor = UIColor.orange

                 let rect = CGRect(x: 0, y: 0, width: 150, height: 200)
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
        
        +++ Section("Girls Profile Image")
        <<< ViewRow<UIView>()
            .cellSetup { (cell, row) in
                cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
                cell.view!.backgroundColor = UIColor.orange

                let rect = CGRect(x: 0, y: 0, width: 150, height: 200)
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
    
    
}
