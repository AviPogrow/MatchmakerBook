//
//  ShadchanGirlNotesVC.swift
//  NasiShadchanHelper
//
//  Created by test on 2/9/22.
//  Copyright © 2022 user. All rights reserved.
//

import UIKit
import Firebase

class ShadchanGirlNotesVC: UITableViewController {

    var isEditingNote: Bool = false
    var notesImageURLString = ""
    var textFieldString = ""
    var selectedGirlNote: ShadchanGirlNote!
    var selectedNasiGirl: NasiGirl!
    
    @IBOutlet weak var notesImageView: UIImageView!
    @IBOutlet weak var notesTextField: UITextView!
    
    //get the notes node
    // get the current user
    // get the current girl
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNoteForGirl()
        
    }
    
    func fetchNoteForGirl() {
      //self.view.showLoadingIndicator()
      
    //  get the node
      let allNotesRef = Database.database().reference().child("ShadchanNotesAndImagesOfNotes")
        
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let currentUserNotesRef = allNotesRef.child(uid)
        let currentGirlUID = selectedNasiGirl.key
    
        let currentUserCurrentGirlNotesRef = currentUserNotesRef.child(currentGirlUID)
        
        currentUserCurrentGirlNotesRef.observe(.value, with: { snapshot in
        
            let snapshot = snapshot as? DataSnapshot
           let note = ShadchanGirlNote(snapshot: snapshot!) as! ShadchanGirlNote
            
            print("the url String is\(note.key)\(note.notesImageURL)")
            
            self.notesImageURLString = note.notesImageURL
            self.textFieldString = note.notesTextString
            
            self.populateImageView()
            self.populateTextField()
            self.tableView.reloadData()
     })
   }
        
    
     func populateImageView() {
        notesImageView.loadImageFromUrl(strUrl: self.notesImageURLString, imgPlaceHolder: "")
    }
    func populateTextField() {
        notesTextField.text = self.textFieldString
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            pickPhoto()
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func doneTapped(_ sender: Any) {
        saveNoteToFirebase()
    }
    
    func saveNoteToFirebase() {
        
        guard let mainView = navigationController?.parent?.view
            else { return }
          let hudView = HudView.hud(inView: mainView, animated: true)
          hudView.text = "Saved"
        
       
        createNewNoteInFirebase()
        
        let delayInSeconds = 0.6
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds)
        {
         hudView.hide()
          self.navigationController?.popViewController(animated: true)
        }
     }
   
    
    @IBAction func notesImageTapped(_ tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            //PRO Tip: don't perform a lot of custom logic inside of a view class
            self.performZoomInForStartingImageView(imageView)
        }
    }
    
    @objc func pincheGestureHandler(recognizer:UIPinchGestureRecognizer){
        //self.view.bringSubview(toFront: imageView)
        recognizer.view?.transform = (recognizer.view?.transform)!.scaledBy(x: recognizer.scale, y: recognizer.scale)
        recognizer.scale = 1.0
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
        zoomingImageView.backgroundColor = UIColor.black
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
    
    func createNewNoteInFirebase() {
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let noteText = notesTextField.text ?? ""
        let timeStamp = "\(Date())"
        let newNote = ShadchanGirlNote(ShachanID: uid, ShadchanEmail: "", ShadchanFirstName: "", ShadchanLastName: "", girlFirstName: "", girlLastName: "", girlRef: "", girlUID: "", notesImageURL: notesImageURLString, notesTextString: noteText, timeStamp: timeStamp)
      
        let girlID = selectedNasiGirl.key
        let ref = Database.database().reference().child("ShadchanNotesAndImagesOfNotes").child(uid).child(girlID)
         
         ref.setValue(newNote.toAnyObject())
        
        
    }
    
    func updateNoteInFirebase() {
      
        let creationDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "MM-dd-yyyy"//"hh:mm:ss a"
       
        let creationDateString = dateFormatter.string(from: creationDate)
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let noteText = notesTextField.text ?? ""
        let timeStamp = "\(Date())"
        let revisedNote = ShadchanGirlNote(ShachanID: "", ShadchanEmail: "", ShadchanFirstName: "", ShadchanLastName: "", girlFirstName: selectedNasiGirl.firstNameOfGirl, girlLastName: selectedNasiGirl.lastNameOfGirl, girlRef: "", girlUID: "", notesImageURL: notesImageURLString, notesTextString: noteText, timeStamp: timeStamp)
        
        let dict = revisedNote.toAnyObject()
        let ref = selectedGirlNote.ref
        ref?.updateChildValues(dict as! [AnyHashable : Any])
    }
    
    
    
    func createNoteInFirebase() {
        /*
        let boyFullName = boysNameTextField.text ?? ""
        let boyCell = boysCellTextField.text ?? ""
        let contactFullName = contactNameTextField.text ?? ""
        let contactCell = contactCellTextField.text ?? ""
        let sendResumeText = sendResumeCellTextField.text ?? ""
        let sendResumeEmail = sendResumeEmailTextField.text ?? ""
        
        let creationDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "MM-dd-yyyy"//"hh:mm:ss a"
       
        let creationDateString = dateFormatter.string(from: creationDate)
        
        let newNote = ShadchanGirlNote(ShachanID: <#T##String#>, ShadchanEmail: <#T##String#>, ShadchanFirstName: <#T##String#>, ShadchanLastName: <#T##String#>, girlFirstName: <#T##String#>, girlLastName: <#T##String#>, girlRef: <#T##String#>, girlUID: <#T##String#>, notesImageURL: <#T##String#>, notesTextString: <#T##String#>, timeStamp: <#T##String#>)
        
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
       print("the uid is \(uid)")
       let dateNodeRef = Database.database().reference().child("NasiBoysList").child(uid)
        let ref = dateNodeRef.childByAutoId()
        ref.setValue(newBoy.toAnyObject())
        */
    }
    
    
    
    
}
extension ShadchanGirlNotesVC:
UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    // MARK: - Image Helper Methods
  func takePhotoWithCamera() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .camera
    imagePicker.delegate = self
    imagePicker.allowsEditing = false
    present(imagePicker, animated: true, completion: nil)
}
    
    func choosePhotoFromLibrary() {
        
        let imagePicker = UIImagePickerController()
      imagePicker.sourceType = .photoLibrary
      imagePicker.delegate = self
      imagePicker.allowsEditing = false
      present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Image Picker Delegates
    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info:
    [UIImagePickerController.InfoKey: Any] ){
     let image = info[UIImagePickerController.InfoKey.originalImage] as?
    UIImage
      if let theImage = image {
        
          show(image: theImage)
          
          view.showLoadingIndicator()
          
          uploadImageAndGetURLAndSetInstanceVar(image: theImage)
        }
      dismiss(animated: true, completion: nil)
    }
    
   @objc func pickPhoto() {
      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        showPhotoMenu()
      } else {
        choosePhotoFromLibrary()
      }
    }
    
    func showPhotoMenu() {
        
        
        
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
                
        
            
        if let popView = alert.popoverPresentationController {
                popView.sourceView = self.notesImageView
                popView.sourceRect = self.notesImageView.frame
            
            present(alert, animated: true, completion: nil)
            }
        }
        
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
        
        
        if let popView = alert.popoverPresentationController {
                popView.sourceView = self.notesImageView
                popView.sourceRect = self.notesImageView.frame
            
            present(alert, animated: true, completion: nil)
        } else {
        present(alert, animated: true, completion: nil)
                }
    }
    
    func show(image: UIImage) {
        notesImageView.image = image
        notesImageView.isHidden = false
      //addPhotoLabel.text = ""
    }
    
    func uploadImageAndGetURLAndSetInstanceVar(image: UIImage) {
        
        print("upload image invoked - image state is \(image)")
        // convert image to jpeg data
        guard let uploadData = image.jpegData(compressionQuality: 0.1) else { return }
        
        let filename = NSUUID().uuidString
        print("the fileName is \(filename)")
        
        let storageRef = Storage.storage().reference().child("ShadchanNotesAndImagesOfNotes").child(filename)
        
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
                
                // set the imageView.image Property
                self.notesImageURLString = imageUrl
                
                self.show(image: image)
                self.view.hideLoadingIndicator()
                
            })
        }
    }
    // pass the url string
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        
    
        
        // if new
        //let ref = shadchanGirlNotesRef.childByAutoId()
        if isEditingNote == false {
        createNewNoteInFirebase()
        } else {
            updateNoteInFirebase()
        }
        self.navigationController?.popViewController(animated: true)
        
        //let selectedBoyImageURLRef = usersBoysListNode.child("boyProfileImageURLString")
        /*
        let ref = userPostRef.childByAutoId()
        
        let values = ["imageUrl": imageUrl,"imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                
                print("Failed to save post to DB", err)
                return
            }
            
            print("Successfully saved post to DB")
         */
          //  self.dismiss(animated: true, completion: nil)
        }
    }
    
