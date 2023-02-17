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

class AddEditGirlViewController: FormViewController {

    
    var selectedShadchanGirl: ShadchanGirl!
    var isEditingGirl = true
    
    let initialHeight = Float(200.0)
    var notesImageView: UIImageView!
    var resumeImageView: UIImageView!
    var girlsPhotoImageView: UIImageView!
    var activeImageView = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
             
             $0.placeholder = "First Name"
               $0.value = selectedShadchanGirl?.girlFirstName ?? ""
               
             $0.onChange { [unowned self] row in //6
                 self.selectedShadchanGirl?.girlFirstName  = row.value ?? ""
             }
          }
         <<< TextRow() {
            $0.placeholder = "Last Name"
             $0.value = selectedShadchanGirl?.girlLastName ?? ""
           $0.onChange { [unowned self] row in //6
        self.selectedShadchanGirl?.girlLastName = row.value ??
               ""
           }
       }
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
                
                
                $0.value  = date
                
                
                $0.onChange { [unowned self] row in //6
                   // self.selectedNasiBoy?.dob = row.value!
                    
                // get date from picker
                let birthday = row.value!
                let dateOfBirth = birthday
                    
                    
                    //var dateCreated = Date()
                // Create Date Formatter
                let dateFormatter = DateFormatter()

                    // Set Date Format
                    dateFormatter.dateFormat = "YY/MM/dd"

                    // Convert Date to String
                    
                    
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
       
        //section 2
    form
        +++
            Section() //section 2
        <<< ActionSheetRow<String>() {
            $0.title = "Girls Height"
            $0.selectorTitle = "Scroll For More Options"
            $0.options = ["4'10\"","4'11\"","5'0\"","5'1\"","5'2\"","5'3\"","5'4\"","5'5\"","5'6\"","5'7\"","5'8\"","5'9\"","5'10\"","5'11\"","6'0\"","6'1\"","6'2\"","6'3\"","N/A\""]
           
            $0.value = self.selectedShadchanGirl?.girlHeight ?? "N/A"
            $0.onChange { [unowned self] row in
            self.selectedShadchanGirl?.girlHeight = row.value ??
                "N/A"
            }
        }
          
        form +++ //section 3
            Section("Girls Cell")
            
            <<< PhoneRow(){
                $0.title = "Cell"
                $0.placeholder = "Add numbers here"
                $0.value =
                self.selectedShadchanGirl?.girlCell ?? "N/A"
                
                $0.onChange { [unowned self] row in
                    self.selectedShadchanGirl?.girlCell = row.value ??
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
                                                                
        let boyCategories = ["FTL - 1-3",
                             "FTL - 3-5",
                             "FTL - 5",
                             "FTL - 5-7",
                             "FTL - 7+",
                             "PTL - School",
                             "PTL - Working",
                             "FTW/College-Yeshiva Style",
                             "FTW/College-Not Yeshiva Style"]
        
        
        for option in boyCategories {
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
            $0.value = selectedShadchanGirl.shadchanNotes ?? ""
            $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            
            $0.onChange { [unowned self] row in //6
                self.selectedShadchanGirl?.shadchanNotes = row.value ?? ""
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
     if section == 5 {
         var values = (row.section as! SelectableSection<ImageCheckRow<String>>).selectedRows().map({$0.baseValue!}) as! [String]
          print(values)
         
         self.selectedShadchanGirl.categories = values
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
    
    
        self.selectedShadchanGirl = ShadchanGirl(girlCell: "", girlLastName: "", girlFirstName: "", calculatedAge: "", dobIntervalString: "", dateCreated: dateCreatedString, dateLastUpdate: updateTimeStamp, girlHeight: "", sendResumeEmail: "", sendResumeText: "", categories: ["",""], shadchanNotes: "", notesImageURL: "", resumeImageURL: "", photoImageURL: "")
       
    }
    
    @objc func saveGirlToFirebase() {
         guard let mainView = navigationController?.parent?.view
             else { return }
           let hudView = HudView.hud(inView: mainView, animated: true)
           hudView.text = "Saved"
         
      
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
          hudView.hide()
           self.navigationController?.popViewController(animated: true)
         }
     }
    
    func saveSelectedShadchanGirlToFB() {
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
       if selectedShadchanGirl.ref != nil {
        
        let nasiBoyNodeRef = Database.database().reference().child("PrivateGirlsList").child(uid)
         
        let selectedNasiBoyRef = selectedShadchanGirl.ref
        selectedNasiBoyRef!.setValue(selectedShadchanGirl.toAnyObject())
        
       } else {
            
            // get uid for current user
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let nasiBoyNodeRef = Database.database().reference().child("PrivateGirlsList").child(uid)
            
            let newNasiBoyRef = nasiBoyNodeRef.childByAutoId()
            newNasiBoyRef.setValue(selectedShadchanGirl.toAnyObject())
            }
        }
    
    @objc func handleDelete() {
        selectedShadchanGirl.ref?.removeValue()
        self.navigationController?.popViewController(animated: true)
        
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
    



