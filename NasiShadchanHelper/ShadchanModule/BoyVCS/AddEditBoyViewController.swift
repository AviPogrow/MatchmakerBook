//
//  AddEditBoyViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 1/29/22.
//  Copyright © 2022 user. All rights reserved.
//


import UIKit
import Eureka
import Firebase
import ImageRow
import ViewRow

class AddEditBoyViewController: FormViewController {
    
    var selectedNasiBoy: NasiBoy!
    var isEditingBoy = true
    
    let initialHeight = Float(200.0)
    var notesImageView: UIImageView!
    var resumeImageView: UIImageView!
    var boysPhotoImageView: UIImageView!
    var matchHimButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationItem.title = "Profile Details"
        
        if selectedNasiBoy != nil {
        let barButtonDelete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handleDelete))
        barButtonDelete.tintColor = UIColor.red
            
            navigationItem.title = selectedNasiBoy.boyFirstName + " " + selectedNasiBoy.boyLastName
        
       let barButtonSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveBoyToFirebase))
        
        navigationItem.rightBarButtonItems = [barButtonSave, barButtonDelete]
            
        } else {
            
            let barButtonSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveBoyToFirebase))
            navigationItem.rightBarButtonItem = barButtonSave
        }
        
        self.tableView.backgroundColor = UIColor.white
        if selectedNasiBoy == nil {
            isEditingBoy = false
            initNewNasiBoy()
            
        }
        
       
        
        
       //1 section 0
     form +++ Section("Boys Name")
          <<< TextRow() {
            
            $0.placeholder = "First Name"
              $0.value = selectedNasiBoy?.boyFirstName ?? ""
              
            $0.onChange { [unowned self] row in //6
                self.selectedNasiBoy?.boyFirstName  = row.value ?? ""
            }
         }
        <<< TextRow() {
           $0.placeholder = "Last Name"
            $0.value = selectedNasiBoy?.boyLastName ?? ""
          $0.onChange { [unowned self] row in //6
       self.selectedNasiBoy?.boyLastName = row.value ??
              ""
          }
      }
        +++ Section("Match Him")
        <<< ViewRow<UIView>()
            .cellSetup { [self] (cell, row) in
            cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 88))
        
            let rect = CGRect(x: 0, y: 0, width: 0, height:0)
            matchHimButton = UIButton(frame: rect)
            matchHimButton.tag = 1001
            matchHimButton.setTitle(title: "Match Him!")
            matchHimButton.titleLabel?.font = .boldSystemFont(ofSize: 26)
            cell.view!.addSubview(matchHimButton)
            matchHimButton.fillSuperview()
            matchHimButton.addTarget(self, action: #selector(self.handleMatchEm), for: .touchUpInside)
           
                if self.selectedNasiBoy.boyFirstName.isEmpty && selectedNasiBoy.boyLastName.isEmpty {
                    matchHimButton.isEnabled = false
                    matchHimButton.backgroundColor = .lightGray
                } else  {
                    matchHimButton.isEnabled = true
                    matchHimButton.backgroundColor = .systemGreen
                }
            }
            
    
        
    
        //section 1
    form  +++ Section()

             <<< DateInlineRow() {
                 $0.title = "Date Of Birth"
            
            if selectedNasiBoy == nil {
                $0.value = Date()
            }
            if selectedNasiBoy != nil {
                // take the interval string and convert it back to
                // int
                let intervalAsInt = Int(selectedNasiBoy.dobIntervalString)
                let intervalAsDouble = Double(selectedNasiBoy.dobIntervalString) ?? 0.0
                let dobString = selectedNasiBoy.dobIntervalString
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
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YY/MM/dd"
                let dateOfBirthString = dateFormatter.string(from: dateOfBirth)
                    
                            
                // calculate age from date of birth
                var currentage = calculateAgeFrom(dob: row.value!)
                    
                let interval = Int(birthday.timeIntervalSince1970)
                    
                // wrap Int as a string
                let dobIntervalString = "\(interval)"
                
                // convert Interval string back to Int
                let intervalBackToInt = Int(string: dobIntervalString)
                    
                    if selectedNasiBoy != nil {
                self.selectedNasiBoy.dobIntervalString = dateOfBirthString
            
                    
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
        $0.title = "Boys Height"
        $0.selectorTitle = "Scroll For More Options"
        $0.options = ["5'0\"","5'1\"","5'2\"","5'3\"","5'4\"","5'5\"","5'6\"","5'7\"","5'8\"","5'9\"","5'10\"","5'11\"","6'0\"","6'1\"","6'2\"","6'3\"","N/A\""]
       
        $0.value = self.selectedNasiBoy?.boyHeight ?? "N/A"
        $0.onChange { [unowned self] row in
        self.selectedNasiBoy?.boyHeight = row.value ??
            "N/A"
        }
    }
        
    form +++ //section 3
        Section("Boys Cell")
        
        <<< PhoneRow(){
            $0.title = "Cell"
            $0.placeholder = "Add numbers here"
            $0.value =
            self.selectedNasiBoy?.boyCell ?? "N/A"
            
            $0.onChange { [unowned self] row in
                self.selectedNasiBoy?.boyCell = row.value ??
                "N/A"
            }
        }
        
        form
            +++
                Section() //section 2
            <<< ActionSheetRow<String>() {
                $0.title = "Boys Status"
                
                $0.selectorTitle = "Choose a Status"
                $0.options = ["available","engaged"]
               
                $0.value = self.selectedNasiBoy?.status ?? "available"
                $0.onChange { [unowned self] row in
                self.selectedNasiBoy?.status = row.value ??
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
                
                let arry = selectedNasiBoy.categories
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
                 $0.value = selectedNasiBoy?.sendResumeEmail  //5
                 
               $0.onChange { [unowned self] row in //6
                   self.selectedNasiBoy?.sendResumeEmail = row.value ?? ""
               }
            }
        
       <<< PhoneRow() {
          
          $0.placeholder = "Cell"
            $0.value = selectedNasiBoy?.sendResumeText  //5
            
          $0.onChange { [unowned self] row in //6
              self.selectedNasiBoy?.sendResumeText = row.value ?? ""
          }
       }
        
        +++ Section("Shadchan Notes")

        <<< TextAreaRow() {
            $0.value = selectedNasiBoy.shadchanNotes ?? ""
            $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            
            $0.onChange { [unowned self] row in //6
                self.selectedNasiBoy?.shadchanNotes = row.value ?? ""
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
            
            let imageURL = self.selectedNasiBoy.notesImageURL ?? ""
            
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
            let imageURL = self.selectedNasiBoy.resumeImageURL ?? ""
            
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
    
        +++ Section("Boys Profile Image")
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
            self.boysPhotoImageView = UIImageView(frame: rect2)
            cell.view?.addSubview(self.boysPhotoImageView)
            self.boysPhotoImageView.backgroundColor = UIColor.groupTableViewBackground
            self.boysPhotoImageView.contentMode = .scaleAspectFit
            self.boysPhotoImageView.isUserInteractionEnabled = true
            self.boysPhotoImageView.layer.cornerRadius = 17
            self.boysPhotoImageView.clipsToBounds = true
            self.boysPhotoImageView.layer.borderWidth = 2.0
            self.boysPhotoImageView.layer.borderColor = UIColor.red.cgColor
            let imageURL = self.selectedNasiBoy.photoImageURL ?? ""
            
            cell.view!.backgroundColor = UIColor.white
            self.boysPhotoImageView.image = UIImage(named: "selected")
            self.boysPhotoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleZoomTap)))
            self.boysPhotoImageView.loadImageFromUrl(strUrl: imageURL, imgPlaceHolder: "")
            
            let rect3 = CGRect(x: 16, y: 16, width: 90, height: 90)
            let label = UILabel(frame: rect3)
            label.adjustsFontSizeToFitWidth
            label.textColor = .systemBlue
            label.text = "Edit Image"
            cell.view!.addSubview(label)
            
        }
        
      
             
        
        
        
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
    
    @objc func handleMatchEm() {
        let categoriesController = storyboard?.instantiateViewController(withIdentifier: "CategoriesViewController") as! CategoriesViewController
        
        if selectedNasiBoy != nil {
       
        categoriesController.selectedNasiBoy = selectedNasiBoy
       self.navigationController?.pushViewController(categoriesController, animated: true)
        }
    }
    
    
    
    
    @objc func handleDelete() {
        
    
      selectedNasiBoy.ref?.removeValue()
        self.navigationController?.popViewController(animated: true)
    
        
        
    }
    
   
    
    @objc func pincheGestureHandler(recognizer:UIPinchGestureRecognizer){
        //self.view.bringSubview(toFront: imageView)
        recognizer.view?.transform = (recognizer.view?.transform)!.scaledBy(x: recognizer.scale, y: recognizer.scale)
        recognizer.scale = 1.0
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
        self.boysPhotoImageView.layer.cornerRadius = 17
        self.boysPhotoImageView.clipsToBounds = true
        self.boysPhotoImageView.layer.borderWidth = 2.0
        self.boysPhotoImageView.layer.borderColor = UIColor.red.cgColor
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.contentMode = .scaleAspectFit
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        var pinchGesture  = UIPinchGestureRecognizer()
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pincheGestureHandler))
 
        zoomingImageView.addGestureRecognizer(pinchGesture)
        
        
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
            

    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        
        /*
       // self.messages = Array(self.messagesDictionary.values)
       // self.messages.sort(by: { (message1, message2) -> Bool in
            
       //     return message1.timestamp?.int32Value > message2.timestamp?.int32Value
        })
        
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
         */
    }
    
    
    
    var activeImageView = 1
    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
        
        let section = row.section!.index!
     if section == 6 {
         var values = (row.section as! SelectableSection<ImageCheckRow<String>>).selectedRows().map({$0.baseValue!}) as! [String]
          print(values)
         
         self.selectedNasiBoy.categories = values
         }
    }
    
    func dowloadImageFromURLAndSet(urlString: String) -> UIImage {
        var downloadedImage: UIImage!
        
        if let url = URL(string: urlString) {
      
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error ?? "")
                return
            }
             downloadedImage = UIImage(data: data!)
                    //imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
            }).resume()
            
        }
        
        return downloadedImage
    }
    
    
        
        
        
    
        
    
    func initNewNasiBoy() {
            let dateCreated  = Date()
        
        let updateTimeStamp = Int(Date().timeIntervalSince1970)
            let dateFormatter = DateFormatter()
        // Set Date Format
        dateFormatter.dateFormat = "YY/MM/dd"
    let dateCreatedString = dateFormatter.string(from: dateCreated)
        
            
        self.selectedNasiBoy = NasiBoy(boyCell: "", boyLastName: "", boyFirstName: "", calculatedAge: "", dobIntervalString: "", dateCreated: dateCreatedString, dateLastUpdate: updateTimeStamp, boyHeight: "", sendResumeEmail: "", sendResumeText: "",categories: ["",""],status: "available", shadchanNotes: "", notesImageURL: "", resumeImageURL: "", photoImageURL: "" )
        }
   
    @IBAction func doneButtonPressed(_ sender: Any) {
        saveBoyToFirebase()
    }
    
   @objc func saveBoyToFirebase() {
        guard let mainView = navigationController?.parent?.view
            else { return }
          let hudView = HudView.hud(inView: mainView, animated: true)
          hudView.text = "Saved"
        
     
        if isEditingBoy == true {
            
            //update the lastUpdate property
        let updateTimeStamp = Int(Date().timeIntervalSince1970)
        self.selectedNasiBoy.dateLastUpdate = updateTimeStamp
        saveSelectedNasiBoyToFB()
        } else {
            saveSelectedNasiBoyToFB()
        }
        
        let delayInSeconds = 0.6
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds)
        {
         hudView.hide()
          self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func saveSelectedNasiBoyToFB() {
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
       if selectedNasiBoy.ref != nil {
        
        let nasiBoyNodeRef = Database.database().reference().child("NasiBoysList").child(uid)
         
        let selectedNasiBoyRef = selectedNasiBoy.ref
        selectedNasiBoyRef!.setValue(selectedNasiBoy.toAnyObject())
        
       } else {
            
            // get uid for current user
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let nasiBoyNodeRef = Database.database().reference().child("NasiBoysList").child(uid)
            
            let newNasiBoyRef = nasiBoyNodeRef.childByAutoId()
            newNasiBoyRef.setValue(selectedNasiBoy.toAnyObject())
            }
        }
    
 
    
    
    
}
extension AddEditBoyViewController:
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
      ppc?.sourceView = self.boysPhotoImageView
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
        ppc?.sourceView = self.boysPhotoImageView
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
          self.boysPhotoImageView.image = theImage
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

    @objc func pickAPhoto () {
   // pickPhoto()
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
            
        self.boysPhotoImageView
        
        if let popView = alert.popoverPresentationController {
            popView.sourceView = self.boysPhotoImageView
            popView.sourceRect = self.boysPhotoImageView.frame
        
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
        
        let storageRef = Storage.storage().reference().child("test_boy_profile_images").child(filename)
        
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
                 self.selectedNasiBoy.notesImageURL = imageUrl
                    
                } else if identifier == "resumeImageURL" {
                    self.selectedNasiBoy.resumeImageURL = imageUrl
                    
                } else if identifier == "photoImageURL" {
                    self.selectedNasiBoy.photoImageURL = imageUrl
                    
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
    





