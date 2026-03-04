//
//  MatchIdeaDetailsViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 2/20/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import Firebase

class MatchIdeaDetailsViewController: UITableViewController {

    var selectedMatchIdea: MatchIdea!
    var boyInfo: NasiBoy!
    var girlInfo: NasiGirl!
    
    @IBOutlet weak var emailResumeLabel: UILabel!
    @IBOutlet weak var textToLabel: UILabel!
    @IBOutlet weak var boysCellLabel: UILabel!
    
    
    @IBOutlet weak var matchIdeasTextView: UITextView!
    
    
    let ideasListRef  = Database.database().reference().child("shadchanNasiMatchIdea")
    
    var ideasArray =  [MatchIdea]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SaveIdea", style: .plain, target: self, action: #selector(saveToIdeas))
        
        let boysName = selectedMatchIdea.boyFirstName + " " + selectedMatchIdea.boyLastName
        let girlsName = selectedMatchIdea.girlFirstName + " " + selectedMatchIdea.girlLastName
        navigationItem.title = "Idea Details"

        let emailResString = "Email Resume To: " +  "\(selectedMatchIdea.boySendResumeEmail)"
        
    emailResumeLabel.text = emailResString
        textToLabel.text = "Email Resume To: " + "\(selectedMatchIdea.boySendResumeText)"
        boysCellLabel.text = "Boys Cell Numb: " +  "\(selectedMatchIdea.boyCell)"
        
        let boyID = selectedMatchIdea.boyID
        let girlID = selectedMatchIdea.girlID
        fetchBoyDataWithID(boyID: boyID)
        fetchGirlDataWithID(girlID: girlID)

       
    }
    func fetchBoyDataWithID(boyID: String) {
        
    }
    func fetchGirlDataWithID(girlID: String) {
     
    }
    
  
    
   
    
    @IBAction func connectWithGirl(_ sender: Any) {
        let contactsController = storyboard!.instantiateViewController(withIdentifier: "ContactsViewController")
        as! ContactsViewController
       // contactsController.selectedNasiGirl = selectedMatchIdea
        
        navigationController?.pushViewController(contactsController, animated: true)
    }
    
    @objc func saveToIdeas() {
        saveIdea()
    }
    
    func saveIdea() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        
        
        let now = "\(Date())"
      
        let dateIdea = MatchIdea(boyID: selectedMatchIdea.boyID, girlID: selectedMatchIdea.girlID, dateCreated:"" , boyFirstName: selectedMatchIdea.boyFirstName, boyLastName: selectedMatchIdea.boyLastName, girlFirstName: selectedMatchIdea.girlFirstName, girlLastName: selectedMatchIdea.girlLastName, girlImageDownloadString: selectedMatchIdea.girlImageDownloadString, girlResumeDownlaodString: selectedMatchIdea.girlResumeDownloadString, boySendResumeEmail: selectedMatchIdea.boySendResumeEmail, boySendResumeText: selectedMatchIdea.boySendResumeText, boyCell: selectedMatchIdea.boyCell, boyPhotoImageURL: selectedMatchIdea.boyPhotoImageURL, currentStage: selectedMatchIdea.currentStage, timeStampForIdea: selectedMatchIdea.timeStampForIdea, timeStampForRedd: "", timeStampForFirstDate: "", timeStampForSecondDate: "", timeStampForThirdDate: "", timeStampForFourthDate: "", dateOfFirstDate: "", dateOfSecondDate: "", dateOfThirdDate: "", dateOfFourthDate: "")
       
        
        let dict = dateIdea.toAnyObject()
      print("the dict is \(dict)")
       
        selectedMatchIdea.ref?.updateChildValues(dict as! [AnyHashable : Any])
        self.navigationController?.popToRootViewController(animated: true)

    }
    

    // MARK: - Table view data source
/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

*/
}
