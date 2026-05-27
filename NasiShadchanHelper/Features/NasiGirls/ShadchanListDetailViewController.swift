 //
 //  ShadchanListDetailViewController.swift
 //  NasiShadchanHelper
 //
 //  Created by user on 5/29/20.
 //  Copyright © 2020 user. All rights reserved.
 //
 
 import UIKit
 import Firebase
 
 
class ShadchanListDetailViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    var onSendResumeTapped: ((NasiGirl) -> Void)?
    var onViewResumeTapped: ((NasiGirl) -> Void)?
    var onContactsTapped: ((NasiGirl) -> Void)?
    var onNotesTapped: ((NasiGirl) -> Void)?

    @IBOutlet weak var lookingForTextView: UITextView!
    
    
    var ref: DatabaseReference!
    
    var selectedNasiGirl: NasiGirl!
    var descriptionArray: [String] = []
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var girlProfileImageView: UIImageView!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var inMatchMode: Bool = false
    var selectedNasiBoy: NasiBoy!
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
    saveProfileViewToFB()
    populateCategoryLabel()
        
        navigationController?.navigationBar.prefersLargeTitles
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send Resume", style: .plain, target: self, action: #selector(presentSendController))
        
        
let matchButton = UIBarButtonItem(title: "Match Them!",style: .plain, target: self, action: #selector(match))
        
        
        //let sendButton = UIBarButtonItem(title: "Send", style: .bordered, target: self, action: #selector(presentSendController))
        //print("nasiboy is \(selectedNasiBoy.debugDescription)")
        
        if selectedNasiBoy == nil {
        //    navigationItem.rightBarButtonItem = sendButton
        }
        if selectedNasiBoy != nil {
            navigationItem.rightBarButtonItem = matchButton

            navigationItem.title = selectedNasiBoy.boyFirstName + " " + selectedNasiBoy.boyLastName
            navigationItem.largeTitleDisplayMode = .always
        }
        
        
    
        
        self.navigationItem.title =
         selectedNasiGirl.nameSheIsCalledOrKnownBy + " " + selectedNasiGirl.lastNameOfGirl
        
        populateBioTextField()
  
        //girlProfileImageView.backgroundColor = .white
        //girlProfileImageView.translatesAutoresizingMaskIntoConstraints = false
       // girlProfileImageView.layer.cornerRadius = 20
        girlProfileImageView.layer.masksToBounds = true
        girlProfileImageView.contentMode = .scaleAspectFill
        girlProfileImageView.isUserInteractionEnabled = true
        girlProfileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        girlProfileImageView.backgroundColor = .yellow
        //girlProfileImageView.image = UIImage(named: "Kramer")
        loadProfilePhoto()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let likeDescription = selectedNasiGirl.briefDescriptionOfWhatGirlIsLike
        let lookingForDescription = selectedNasiGirl.briefDescriptionOfWhatGirlIsLookingFor
        let doingDescription = selectedNasiGirl.briefDescriptionOfWhatGirlIsDoing
        
        descriptionArray = [likeDescription,lookingForDescription,doingDescription]
        
        }
    
    @objc func handleSendResume() {
        
    }
    
    func saveProfileViewToFB() {
        let now = "\(Date())"
        let girlID = selectedNasiGirl.key
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let profileView = ProfileView(timesStamp: now, girlID: girlID, shadchanID: uid)
        
        let profileViewDict = profileView.toAnyObject()
        
        let profileViewFBNode = Database.database().reference().child("GirlProfileViews").child(uid)
        let currentProfileViewRef = profileViewFBNode.childByAutoId()
        currentProfileViewRef.setValue(profileViewDict)
        
    }
    func populateCategoryLabel(){
    categoryLabel.text =  "Categories - " +
        selectedNasiGirl.category + " " +   selectedNasiGirl.yearsOfLearning
    }
    
    @objc func addToFavorites() {
        
    }
    @objc func match() {
        
        
        let matchView = MatchView(frame: self.view.bounds)
        matchView.selectedNasiGirl = selectedNasiGirl
        matchView.descriptionText = selectedNasiGirl.firstNameOfGirl  + " " +
        selectedNasiGirl.lastNameOfGirl + " & " +
        selectedNasiBoy.boyFirstName + " " + selectedNasiBoy.boyLastName
        //matchView.selectedNasiBoy = selectedNasiBoy
        view.addSubview(matchView)
        
    }
    var visualEffectView: UIVisualEffectView!
    
    @objc func presentMatchView() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        visualEffectView.frame = self.view.bounds
        
        view.addSubview(visualEffectView)
      
        visualEffectView.alpha = 1
        
        /*
        UIView.animate(withDuration: 2.5, delay: 2, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.visualEffectView.alpha = 1
        }) { (_) in
            
        }
       */
    }
    @objc fileprivate func handleTapDismiss() {
        
        
        UIView.animate(withDuration: 0.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.visualEffectView.alpha = 0
        }) { (_) in
            self.self.visualEffectView.removeFromSuperview()
        }
    }
    
  @objc  func saveMatchIdeaToFirebase() {
        print("state of nasiBoy is \(selectedNasiBoy) and girl is \(selectedNasiGirl)")
      
      
         
        // get uid for current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let shadchanNasiMatchIdeaRef = Database.database().reference().child("shadchanNasiMatchIdea").child(uid)
                
      let boysName = selectedNasiBoy.boyFirstName + " " + selectedNasiBoy.boyLastName
      let girlsName = selectedNasiGirl.firstNameOfGirl + " " + selectedNasiGirl.lastNameOfGirl
      
      
      let boyFirstName = selectedNasiBoy.boyFirstName
      let boyLastName = selectedNasiBoy.boyLastName
      let girlFirstName = selectedNasiGirl.firstNameOfGirl
      let girlLastName = selectedNasiGirl.lastNameOfGirl
      
      let girlImageDownloadString = selectedNasiGirl.imageDownloadURLString
      let girlResumeDownloadString = selectedNasiGirl.documentDownloadURLString
      
      let boySendResumeEmail = selectedNasiBoy.sendResumeEmail ?? "N/A"
      let boySendResumeText = selectedNasiBoy.sendResumeText ?? "N/A"
      let boyPersonToRedd = selectedNasiBoy.boyCell ?? "N/A"
      let boyPhotoImageURL =  selectedNasiBoy.photoImageURL
      
     
      
      let newMatch = MatchIdea(boyID: selectedNasiBoy.key, girlID: selectedNasiGirl.key, dateCreated: "\(Date())", boyFirstName: selectedNasiBoy.boyFirstName, boyLastName: selectedNasiBoy.boyLastName, girlFirstName: selectedNasiGirl.firstNameOfGirl, girlLastName: selectedNasiGirl.lastNameOfGirl, girlImageDownloadString: selectedNasiGirl.imageDownloadURLString, girlResumeDownlaodString: selectedNasiGirl.documentDownloadURLString, boySendResumeEmail: selectedNasiBoy.sendResumeEmail, boySendResumeText: selectedNasiBoy.sendResumeText, boyCell: selectedNasiBoy.boyCell, boyPhotoImageURL: selectedNasiBoy.photoImageURL, currentStage: "idea", timeStampForIdea: "\(Date())", timeStampForRedd: "", timeStampForFirstDate: "", timeStampForSecondDate: "", timeStampForThirdDate: "", timeStampForFourthDate: "", dateOfFirstDate: "", dateOfSecondDate: "", dateOfThirdDate: "", dateOfFourthDate: "")
      
      print(newMatch.description)
      
        let dict = newMatch.toAnyObject()
        let newshadchanNasiMatchIdeaRef = shadchanNasiMatchIdeaRef.childByAutoId()
        newshadchanNasiMatchIdeaRef.setValue(dict)
        
        self.navigationController?.popToRootViewController(animated: true)
    }
            
    
    func populateBioTextField() {
    
        let AgeString =  "\(selectedNasiGirl.age)"
        let heightString = "\(selectedNasiGirl.heightInFeet)" + "\'" + " " + "\(selectedNasiGirl.heightInInches)"  + "\""
        let cityString = "\(selectedNasiGirl.cityOfResidence)"
        let seminaryString = "\(selectedNasiGirl.seminaryName)"
        let familySituationString = "\(selectedNasiGirl.girlFamilySituation)"
        let familyBackGroundString = "\(selectedNasiGirl.girlFamilyBackground)"
        
        let planString = "\(selectedNasiGirl.plan)"
        
        
        let learningIsraelString = "\(selectedNasiGirl.livingInIsrael)"
        
        let attributedText = NSMutableAttributedString(string: "Age:  ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22)])
        
        attributedText.append(NSAttributedString(string: AgeString, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
    
        attributedText.append(NSAttributedString(string: "Height:  ", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: heightString, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]))
        
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: "City:  ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: cityString, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: "Seminary:  ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: seminaryString, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]))
        
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: "Family Situation:  ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: familySituationString, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: "Family Background:  ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: familyBackGroundString, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: "Learning Plan:  ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: planString, attributes:  [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: "Learning Israel:  ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: learningIsraelString, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        //label.attributedText = attributedText
        lookingForTextView.attributedText = attributedText
    }
   
   @objc func presentSendController(){
    
           onSendResumeTapped?(selectedNasiGirl)
       }
        
    
        
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
        
         if segue.identifier == "ShowViewResumeVC" {
        let controller = segue.destination as! ViewResumeVCViewController
           
            controller.selectedNasiGirl  = self.selectedNasiGirl
            
        }
        
        else if segue.identifier == "ShowContactsVC" {
        let controller = segue.destination as! ContactsViewController
           
            controller.selectedNasiGirl  = self.selectedNasiGirl
        }
        
        else if segue.identifier == "ShowNotesVC" {
        let controller = segue.destination as! ShadchanGirlNotesVC
           
            controller.selectedNasiGirl  = self.selectedNasiGirl
        }
        
    }
    
    func loadProfilePhoto(){
    girlProfileImageView.loadImageFromUrl(strUrl: selectedNasiGirl.imageDownloadURLString, imgPlaceHolder:"")
        
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
        zoomingImageView.backgroundColor = UIColor.black
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.contentMode = .scaleAspectFill
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
    
    @objc func pincheGestureHandler(recognizer:UIPinchGestureRecognizer){
        //self.view.bringSubview(toFront: imageView)
        recognizer.view?.transform = (recognizer.view?.transform)!.scaledBy(x: recognizer.scale, y: recognizer.scale)
        recognizer.scale = 1.0
    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.contentMode = .scaleAspectFill
            zoomOutImageView.backgroundColor = .black
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


func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return descriptionArray.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
   let cellID = "cellID"
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! DescriptionCollectionViewCell
    
    let whatsSheLike = "Whats she like?"
    let whatsShelookingFor = "Whats she looking for?"
    let whatsSheDoing = "Whats she currently doing?"
    
    cell.descriptionTextView.text = descriptionArray[indexPath.row]
    
    cell.layer.borderWidth = 0.25
    cell.layer.borderColor = UIColor.systemPink.cgColor
    return cell
}

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 1
}

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 1
}

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width =    (collectionView.frame.width - 20) //300
    return CGSize(width: width, height: width)
}
}
   
    
 
