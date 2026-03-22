//
//  AddEditGirlViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 2/12/23.
//  Copyright © 2023 user. All rights reserved.
//import UIKit
import Eureka
import Firebase
import ImageRow
import ViewRow
import Contacts
import ContactsUI
import Combine

class AddEditGirlViewController: FormViewController, CNContactPickerDelegate, ResumeScanVCDelegate, GirlDraftProvider, NavigationStateProvider {
    
    private var notesImageUploadSpinner: UIActivityIndicatorView?
    private var resumeImageUploadSpinner: UIActivityIndicatorView?
    private var profileImageUploadSpinner: UIActivityIndicatorView?
    
    private var saveButton: UIBarButtonItem?
    private var pendingImageUploadCount = 0
    
    // MARK: Age row and Dob row sync
    var isSyncingDOBAndAge = false
    
    var shouldPresentAddOptionsOnFirstAppearance = false
    private var hasPresentedAddOptions = false

    // MARK: Data Model
    var selectedShadchanGirl: ShadchanGirl!
    var isEditingGirl = true

    // MARK: ImageView Handlers
    var notesImageView: UIImageView!
    var resumeImageView: UIImageView!
    var girlsPhotoImageView: UIImageView!
    
    private var activeImageKind: ImageKind?
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    // MARK: Debounced Autosave
    private let draftDidChangeSubject = PassthroughSubject<Void, Never>()

    /// Stores Combine subscriptions so they stay alive
    /// for as long as this view controller is alive.
    private var cancellables = Set<AnyCancellable>()
    
    /// Guards autosave / row-driven side effects while the controller
    /// is applying programmatic form changes (draft restore, contact import,
    /// resume scan, DOB/age sync, etc.)
    private var isRestoringFormState = false
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

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
        notifyDraftDidChange()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DraftManager.shared.activeDraftProvider = self
        NavigationStateManager.shared.activeProvider = self

        guard shouldPresentAddOptionsOnFirstAppearance else { return }
        guard !hasPresentedAddOptions else { return }

        hasPresentedAddOptions = true
        showAddGirlOptions()
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

// MARK: Data Model
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

// MARK: Firebase Persistence
extension AddEditGirlViewController {
   
 private   func uploadImageAndStoreURL(image: UIImage, kind: ImageKind, identifier: String) {
        pendingImageUploadCount += 1
        updateSaveButtonState()
        setUploading(true, for: kind)
        view.showLoadingIndicator()

        ImageUploadService.shared.uploadImage(image) { [weak self] result in
            guard let self else { return }

            defer {
                self.pendingImageUploadCount = max(0, self.pendingImageUploadCount - 1)
                self.updateSaveButtonState()
                self.setUploading(false, for: kind)

                if self.pendingImageUploadCount == 0 {
                    self.view.hideLoadingIndicator()
                }
            }

            switch result {
            case .success(let imageURL):
                if identifier == "notesImageURL" {
                    self.selectedShadchanGirl.notesImageURL = imageURL
                } else if identifier == "resumeImageURL" {
                    self.selectedShadchanGirl.resumeImageURL = imageURL
                } else if identifier == "photoImageURL" {
                    self.selectedShadchanGirl.photoImageURL = imageURL
                }

                self.notifyDraftDidChange()

            case .failure(let error):
                print("Image upload failed:", error)
            }
        }
    }
    
    @objc func saveGirlToFirebase() {
        guard pendingImageUploadCount == 0 else {
            let alert = UIAlertController(
                title: "Images Still Uploading",
                message: "Please wait for image uploads to finish before saving.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

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
    
    private enum ImageKind {
        case notes
        case resume
        case profile

        var sectionTitle: String {
            switch self {
            case .notes: return "Photo of Notes"
            case .resume: return "Photo of Resume"
            case .profile: return "Girls Profile Image"
            }
        }
     

        
        var pickerTag: Int {
            switch self {
            case .notes: return 101
            case .resume: return 102
            case .profile: return 103
            }
        }
        init?(pickerTag: Int) {
            switch pickerTag {
            case 101: self = .notes
            case 102: self = .resume
            case 103: self = .profile
            default: return nil
            }
        }
        
    }
    
    private func uploadSpinner(for kind: ImageKind) -> UIActivityIndicatorView? {
        switch kind {
        case .notes:
            return notesImageUploadSpinner
        case .resume:
            return resumeImageUploadSpinner
        case .profile:
            return profileImageUploadSpinner
        }
    }

    private func storeUploadSpinner(_ spinner: UIActivityIndicatorView, for kind: ImageKind) {
        switch kind {
        case .notes:
            notesImageUploadSpinner = spinner
        case .resume:
            resumeImageUploadSpinner = spinner
        case .profile:
            profileImageUploadSpinner = spinner
        }
    }
    
    
    private func imageURL(for kind: ImageKind) -> String {
        switch kind {
        case .notes:
            return selectedShadchanGirl.notesImageURL ?? ""
        case .resume:
            return selectedShadchanGirl.resumeImageURL ?? ""
        case .profile:
            return selectedShadchanGirl.photoImageURL ?? ""
        }
    }
    private func setUploading(_ isUploading: Bool, for kind: ImageKind) {
        guard let spinner = uploadSpinner(for: kind),
              let imageView = imageView(for: kind) else { return }

        imageView.alpha = isUploading ? 0.7 : 1.0

        if isUploading {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
    }
    
    private func imageView(for kind: ImageKind) -> UIImageView? {
        switch kind {
        case .notes:
            return notesImageView
        case .resume:
            return resumeImageView
        case .profile:
            return girlsPhotoImageView
        }
    }

    private func storeImageView(_ imageView: UIImageView, for kind: ImageKind) {
        switch kind {
        case .notes:
            notesImageView = imageView
        case .resume:
            resumeImageView = imageView
        case .profile:
            girlsPhotoImageView = imageView
        }
    }
    
    private func makeImageSection(for kind: ImageKind) -> Section {
        let section = Section(kind.sectionTitle)

        section <<< ViewRow<UIView>().cellSetup { [weak self] cell, row in
            guard let self else { return }

            cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
            cell.view?.backgroundColor = .white

            let editTapArea = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 200))
            editTapArea.isUserInteractionEnabled = true
            editTapArea.tag = kind.pickerTag
            editTapArea.backgroundColor = .white
            cell.view?.addSubview(editTapArea)

            editTapArea.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(self.pickPhoto))
            )

            let previewImageView = UIImageView(frame: CGRect(x: 150, y: 0, width: 200, height: 200))
            previewImageView.backgroundColor = UIColor.groupTableViewBackground
            previewImageView.contentMode = .scaleAspectFit
            previewImageView.isUserInteractionEnabled = true
            previewImageView.layer.cornerRadius = 17
            previewImageView.layer.borderWidth = 2.0
            previewImageView.layer.borderColor = UIColor.red.cgColor
            previewImageView.clipsToBounds = true

            cell.view?.addSubview(previewImageView)
            self.storeImageView(previewImageView, for: kind)
            
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.hidesWhenStopped = true
            previewImageView.addSubview(spinner)

            NSLayoutConstraint.activate([
                spinner.centerXAnchor.constraint(equalTo: previewImageView.centerXAnchor),
                spinner.centerYAnchor.constraint(equalTo: previewImageView.centerYAnchor)
            ])

            self.storeUploadSpinner(spinner, for: kind)

            previewImageView.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(self.handleZoomTap))
            )

            let imageURL = self.imageURL(for: kind)

            if kind == .profile {
                previewImageView.image = UIImage(named: "selected")
            }

            previewImageView.loadImageFromUrl(strUrl: imageURL, imgPlaceHolder: "")

            let label = UILabel(frame: CGRect(x: 16, y: 16, width: 90, height: 90))
            label.adjustsFontSizeToFitWidth = true
            label.textColor = .systemBlue
            label.text = "Edit Image"
            cell.view?.addSubview(label)
        }

        return section
    }
    

    // MARK: Image Helper Methods
    
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
        guard let tappedView = tapGesture.view as? UIImageView,
              let kind = ImageKind(pickerTag: tappedView.tag) else { return }

        activeImageKind = kind

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
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        let image = info[.originalImage] as? UIImage

        guard let selectedImage = image,
              let kind = activeImageKind else {
            dismiss(animated: true, completion: nil)
            return
        }

        imageView(for: kind)?.image = selectedImage

        let identifier: String
        switch kind {
        case .notes:
            identifier = "notesImageURL"
        case .resume:
            identifier = "resumeImageURL"
        case .profile:
            identifier = "photoImageURL"
        }

        uploadImageAndStoreURL(image: selectedImage, kind: kind, identifier: identifier)
        
        activeImageKind = nil
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        activeImageKind = nil
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
}

extension AddEditGirlViewController {
    
    // MARK: Autosave
    
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
        guard !isRestoringFormState else { return }
        draftDidChangeSubject.send(())
    }
    
    private func setupDebouncedAutosave() {
        draftDidChangeSubject
            .debounce(for: .milliseconds(800), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.saveDraftFromCurrentFormState()
            }
            .store(in: &cancellables)
    }
    
    private func saveDraftFromCurrentFormState() {
        let draft = makeDraft()
        DraftManager.shared.saveDraft(draft)
        print("💾 Debounced autosave triggered")
    }
}

extension AddEditGirlViewController {
    // MARK: Import from Contacts
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
    // MARK: External Data Application
    private struct IncomingGirlData {
        var firstName: String?
        var lastName: String?
        var cell: String?
        var city: String?
        var height: String?
        var dobISO: String?
        var email: String?
        var sendResumeText: String?
    }
    private func applyIncomingDataToModel(_ data: IncomingGirlData) {
        if let firstName = data.firstName, !firstName.isEmpty {
            selectedShadchanGirl.girlFirstName = firstName
        }

        if let lastName = data.lastName, !lastName.isEmpty {
            selectedShadchanGirl.girlLastName = lastName
        }

        if let cell = data.cell, !cell.isEmpty {
            selectedShadchanGirl.girlCell = cell
        }

        if let city = data.city, !city.isEmpty {
            selectedShadchanGirl.city = city
        }

        if let height = data.height, !height.isEmpty {
            selectedShadchanGirl.girlHeight = height
        }

        if let email = data.email, !email.isEmpty {
            selectedShadchanGirl.sendResumeEmail = email
        }

        if let sendResumeText = data.sendResumeText, !sendResumeText.isEmpty {
            selectedShadchanGirl.sendResumeText = sendResumeText
        }

        if let dobISO = data.dobISO, !dobISO.isEmpty {
            selectedShadchanGirl.dobIntervalString = dobISO
        }
    }
    
    private func populateFormRows(from data: IncomingGirlData) {
        if let firstName = data.firstName, !firstName.isEmpty,
           let row = form.rowBy(tag: "firstName") as? TextRow {
            row.value = firstName
            row.updateCell()
        }

        if let lastName = data.lastName, !lastName.isEmpty,
           let row = form.rowBy(tag: "lastName") as? TextRow {
            row.value = lastName
            row.updateCell()
        }

        if let cell = data.cell, !cell.isEmpty,
           let row = form.rowBy(tag: "cell") as? PhoneRow {
            row.value = cell
            row.updateCell()
        }

        if let city = data.city, !city.isEmpty,
           let row = form.rowBy(tag: "city") as? TextRow {
            row.value = city
            row.updateCell()
        }

        if let height = data.height, !height.isEmpty,
           let row = form.rowBy(tag: "height") as? ActionSheetRow<String> {
            row.value = height
            row.updateCell()
        }

        if let email = data.email, !email.isEmpty,
           let row = form.rowBy(tag: "email") as? TextRow {
            row.value = email
            row.updateCell()
        }

        if let sendResumeText = data.sendResumeText, !sendResumeText.isEmpty,
           let row = form.rowBy(tag: "sendResumeText") as? PhoneRow {
            row.value = sendResumeText
            row.updateCell()
        }
    }
    
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
    
    /// Nesting-safe wrapper for programmatic form mutations.
    /// If one programmatic update calls another, the original restore state
    /// is preserved correctly.
    private func performProgrammaticFormUpdate(_ updates: () -> Void) {
        let wasRestoring = isRestoringFormState
        isRestoringFormState = true
        defer { isRestoringFormState = wasRestoring }
        updates()
    }

    
     func didScanAndParseResume(dict: [String: String]) {
         func clean(_ key: String) -> String {
             (dict[key] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
         }

         let rawDOB = clean("dob")
         let normalizedDOB = ISODateOnly.normalizeToISO(rawDOB)

         let data = IncomingGirlData(
             firstName: clean("firstName"),
             lastName: clean("lastName"),
             cell: clean("telephone"),
             city: clean("city"),
             height: clean("height"),
             dobISO: normalizedDOB,
             email: nil,
             sendResumeText: nil
         )

         performProgrammaticFormUpdate {
             applyIncomingDataToModel(data)
             populateFormRows(from: data)

             if let iso = data.dobISO,
                let dobDate = ISODateOnly.dateForDateRow(fromISO: iso) {
                 applyDOB(dobDate)
             }
         }

         notifyDraftDidChange()
     }
     
   
    func importContact(_ contact: CNContact) {
        let phoneNumbers = contact.phoneNumbers.map { $0.value as CNPhoneNumber }
        let emails = contact.emailAddresses.map { $0.value as String }
        let address = contact.postalAddresses.first?.value as CNPostalAddress?

        let data = IncomingGirlData(
            firstName: contact.givenName,
            lastName: contact.familyName,
            cell: phoneNumbers.first?.stringValue ?? "",
            city: address?.city ?? "Not Found",
            height: nil,
            dobISO: nil,
            email: emails.first ?? "",
            sendResumeText: nil
        )

        performProgrammaticFormUpdate {
            applyIncomingDataToModel(data)
            populateFormRows(from: data)
        }

        notifyDraftDidChange()
    }
 func applyDraft(_ draft: GirlDraft) {
     performProgrammaticFormUpdate {
         updateSelectedGirl(from: draft)
         populateFormRows(from: draft)

         if let iso = ISODateOnly.normalizeToISO(draft.dobIntervalString),
            let date = ISODateOnly.dateForDateRow(fromISO: iso) {
             applyDOB(date)
         }

         populateLifePlanSection(with: draft.lifePlans)
     }
 }
 
    // MARK: - Draft Restoration Mapping
    
    private func updateSelectedGirl(from draft: GirlDraft) {
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
    }
    
    private func populateFormRows(from draft: GirlDraft) {
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
    }
    
    private func populateLifePlanSection(with selectedPlans: [String]) {
        if let section = form.sectionBy(tag: "lifePlansSection") as? SelectableSection<ImageCheckRow<String>> {
            for baseRow in section.allRows {
                guard let row = baseRow as? ImageCheckRow<String>,
                      let value = row.selectableValue else { continue }

                row.value = selectedPlans.contains(value) ? value : nil
                row.updateCell()
            }
        }
    }
}

extension AddEditGirlViewController {
    // MARK: DOB <-> Age Sync
    
    private func applyAge(_ ageEntered: Int) {
        guard !isSyncingDOBAndAge else { return }
        
        isSyncingDOBAndAge = true
        defer { isSyncingDOBAndAge = false }

        let dob = dobByAddingYears(numberOfYears: ageEntered)
        let iso = ISODateOnly.iso(from: dob)

        performProgrammaticFormUpdate {
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
    }
    
    private func applyDOB(_ date: Date) {
        guard !isSyncingDOBAndAge else { return }
        
        isSyncingDOBAndAge = true
        defer { isSyncingDOBAndAge = false }

        let iso = ISODateOnly.iso(from: date)

        performProgrammaticFormUpdate {
            selectedShadchanGirl.dobIntervalString = iso

            if let dobRow = form.rowBy(tag: "dob") as? DateRow {
                dobRow.value = ISODateOnly.dateForDateRow(fromISO: iso)
                dobRow.updateCell()
            }

            let ageYears = calculateAgeYears(fromDOBISO: iso)
            if let ageRow = form.rowBy(tag: "age") as? IntRow {
                ageRow.value = (ageYears > 0) ? ageYears : nil
                ageRow.updateCell()
            }
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
    // MARK: State Restoration
    func makeNavigationState() -> NavigationState {
        let tabIndex = tabBarController?.selectedIndex ?? 0

        return NavigationState(
            screenID: "addEditGirl",
            isEditingGirl: isEditingGirl,
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

// MARK: Setup Scene
extension AddEditGirlViewController {
    private func configureScreenMode() {
        if isEditingGirl {
            navigationItem.title = "Edit Profile"

            let barButtonDelete = UIBarButtonItem(
                title: "Delete",
                style: .plain,
                target: self,
                action: #selector(deleteTapped)
            )
            barButtonDelete.tintColor = .red

            let barButtonSave = UIBarButtonItem(
                title: "Save",
                style: .plain,
                target: self,
                action: #selector(saveGirlToFirebase)
            )

            saveButton = barButtonSave
            navigationItem.rightBarButtonItems = [barButtonSave, barButtonDelete]

        } else {
            navigationItem.title = "Add Profile Details"
            initNewNasiGirl()

            let barButtonSave = UIBarButtonItem(
                title: "Save",
                style: .plain,
                target: self,
                action: #selector(saveGirlToFirebase)
            )

            saveButton = barButtonSave
            navigationItem.rightBarButtonItem = barButtonSave
        }

        updateSaveButtonState()
    }
    private func updateSaveButtonState() {
        let isUploading = pendingImageUploadCount > 0

        saveButton?.isEnabled = !isUploading
        saveButton?.title = isUploading ? "Uploading..." : "Save"
    }
    
    private func configureTableView() {
        self.tableView.backgroundColor = UIColor.white
    }
    
    // MARK: Form Construction
    private func buildForm() {
        buildCoreProfileSections()
        buildStatusAndLifePlansSections()
        buildResumeContactAndNotesSections()
        buildImageSections()
    }
    
    
    
    // MARK: Form Section Builders
    private func buildCoreProfileSections() {
        
        form +++ Section("Girls Name")
        <<< TextRow() {
            $0.tag = "firstName"
            $0.placeholder = "First Name"
            bindTextRow($0, initialValue: selectedShadchanGirl?.girlFirstName ?? "") { [weak self] value in
                self?.selectedShadchanGirl?.girlFirstName = value
            }
        }

        <<< TextRow() {
            $0.placeholder = "Last Name"
            $0.tag = "lastName"
            bindTextRow($0, initialValue: selectedShadchanGirl?.girlLastName ?? "") { [weak self] value in
                self?.selectedShadchanGirl?.girlLastName = value
            }
        }
        
        form +++ Section("Girls Cell")
        <<< PhoneRow() {
            $0.title = "Cell"
            $0.tag = "cell"
            $0.placeholder = "Add numbers here"
            bindPhoneRow($0, initialValue: selectedShadchanGirl?.girlCell ?? "N/A", fallback: "N/A") { [weak self] value in
                self?.selectedShadchanGirl?.girlCell = value
            }
        }

        <<< TextRow() {
            $0.tag = "city"
            $0.placeholder = "City"
            bindTextRow($0, initialValue: selectedShadchanGirl?.city ?? "") { [weak self] value in
                self?.selectedShadchanGirl?.city = value
            }
        }

        form +++ Section("Girls Age")
        <<< makeAgeRow()

        form +++ Section()
        <<< makeDOBRow()

        form +++ Section()
        <<< ActionSheetRow<String>() {
            $0.tag = "height"
            $0.title = "Girls Height"
            $0.selectorTitle = "Scroll For More Options"
            $0.options = ["4'10\"","4'11\"","5'0\"","5'1\"","5'2\"","5'3\"","5'4\"","5'5\"","5'6\"","5'7\"","5'8\"","5'9\"","5'10\"","5'11\"","6'0\"","6'1\"","6'2\"","6'3\"","N/A"]

            bindActionSheetRow($0, initialValue: selectedShadchanGirl?.girlHeight ?? "N/A", fallback: "N/A") { [weak self] value in
                self?.selectedShadchanGirl?.girlHeight = value
            }
        }
    }
    private func buildStatusAndLifePlansSections() {
        form
        +++
        Section()
        <<< ActionSheetRow<String>() {
            $0.title = "Girls Status"
            $0.selectorTitle = "Choose a Status"
            $0.options = ["available","engaged"]
            $0.value = self.selectedShadchanGirl?.status ?? "available"
            $0.onChange { [unowned self] row in
                self.selectedShadchanGirl?.status = row.value ?? "available"
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
            bindTextRow($0, initialValue: selectedShadchanGirl?.sendResumeEmail) { [weak self] value in
                self?.selectedShadchanGirl?.sendResumeEmail = value
            }
        }

        <<< PhoneRow() {
            $0.tag = "sendResumeText"
            $0.placeholder = "Cell"
            bindPhoneRow($0, initialValue: selectedShadchanGirl?.sendResumeText, fallback: "") { [weak self] value in
                self?.selectedShadchanGirl?.sendResumeText = value
            }
        }

        <<< TextAreaRow() {
            $0.tag = "shadchanNotesNew"
            $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            bindTextAreaRow($0, initialValue: selectedShadchanGirl.shadchanNotesNew) { [weak self] value in
                self?.selectedShadchanGirl?.shadchanNotesNew = value
            }
        }
    }
    
    private func buildImageSections() {
        form
            +++ makeImageSection(for: .notes)
            +++ makeImageSection(for: .resume)
            +++ makeImageSection(for: .profile)
    }
    
       
    
    // MARK: Form Row Builders
    private func makeAgeRow() -> IntRow {
        return IntRow() { row in
            row.tag = "age"
            row.title = "Age"
            row.placeholder = "Enter Girl's Age"
            
            let rawDOB = selectedShadchanGirl.dobIntervalString
            if let iso = ISODateOnly.normalizeToISO(rawDOB) {
                if iso != rawDOB {
                    selectedShadchanGirl.dobIntervalString = iso
                }
                
                let ageYears = calculateAgeYears(fromDOBISO: iso)
                row.value = (ageYears > 0) ? ageYears : nil
            } else {
                row.value = nil
            }
            
            row.onChange { [unowned self] row in
                guard !self.isSyncingDOBAndAge else { return }
                guard !self.isRestoringFormState else { return }
                guard let age = row.value, age > 0 else { return }
                
                self.applyAge(age)
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
                selectedShadchanGirl.dobIntervalString = iso
                row.value = date
            } else {
                row.value = nil
            }

            row.onChange { [unowned self] row in
                guard !self.isSyncingDOBAndAge else { return }
                guard !self.isRestoringFormState else { return }
                guard let date = row.value else { return }

                self.applyDOB(date)
                self.notifyDraftDidChange()
            }
        }
    }
}
extension AddEditGirlViewController {
    
    private func bindTextRow(
        _ row: TextRow,
        initialValue: String?,
        assign: @escaping (String) -> Void
    ) {
        row.value = initialValue
        row.onChange { [unowned self] changedRow in
            assign(changedRow.value ?? "")
            self.notifyDraftDidChange()
        }
    }
    
    private func bindPhoneRow(
        _ row: PhoneRow,
        initialValue: String?,
        fallback: String = "",
        assign: @escaping (String) -> Void
    ) {
        row.value = initialValue
        row.onChange { [unowned self] changedRow in
            assign(changedRow.value ?? fallback)
            self.notifyDraftDidChange()
        }
    }
    
    private func bindActionSheetRow(
        _ row: ActionSheetRow<String>,
        initialValue: String?,
        fallback: String = "",
        assign: @escaping (String) -> Void
    ) {
        row.value = initialValue
        row.onChange { [unowned self] changedRow in
            assign(changedRow.value ?? fallback)
            self.notifyDraftDidChange()
        }
    }
    
    private func bindTextAreaRow(
        _ row: TextAreaRow,
        initialValue: String?,
        assign: @escaping (String) -> Void
    ) {
        row.value = initialValue
        row.onChange { [unowned self] changedRow in
            assign(changedRow.value ?? "")
            self.notifyDraftDidChange()
        }
    }
}

