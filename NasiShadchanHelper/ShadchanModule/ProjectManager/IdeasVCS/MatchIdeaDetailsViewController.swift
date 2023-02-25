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
    let ideasListRef  = Database.database().reference().child("shadchanNasiMatchIdea")
    var ideasArray =  [MatchIdea]()
    let reddsListRef = Database.database().reference().child("ShadchanReddsList")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let boysName = selectedMatchIdea.boyFirstName + " " + selectedMatchIdea.boyLastName
        let girlsName = selectedMatchIdea.girlFirstName + " " + selectedMatchIdea.girlLastName
        navigationItem.title = "\(boysName)" + " & " + "\(girlsName)"

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
    
    @IBAction func saveIdeaToReddsList(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // redd node - current user - add to redd list
        let reddRef = reddsListRef.child(uid)
        
        let now = "\(Date())"
        let newRedd = ShadchanRedd(boyID: selectedMatchIdea.boyID, girlID: selectedMatchIdea.girlID,
        dateCreated: now, boyFirstName: selectedMatchIdea.boyFirstName, boyLastName: selectedMatchIdea.boyLastName, girlFirstName: selectedMatchIdea.girlFirstName, girlLastName: selectedMatchIdea.girlLastName, girlImageDownloadString: selectedMatchIdea.girlImageDownloadString, girlResumeDownlaodString: selectedMatchIdea.girlResumeDownloadString, boySendResumeEmail: selectedMatchIdea.boySendResumeEmail, boySendResumeText: selectedMatchIdea.boySendResumeText, boyCell: selectedMatchIdea.boyCell,
            boyPhotoImageURL: selectedMatchIdea.boyPhotoImageURL)
       
          let dict = newRedd.toAnyObject()
        print("the dict is \(dict)")
        
        
        
        
          let newShadchanReddRef = reddRef.childByAutoId()
          newShadchanReddRef.setValue(dict)
          
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func sendGirlData(_ sender: Any) {
        
        let sendController = storyboard!.instantiateViewController(withIdentifier: "ResumeViewController") as! ResumeViewController
        
         
        sendController.selectedMatchIdea = selectedMatchIdea
        
        navigationController?.pushViewController(sendController, animated: true)
        
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
*/
}
