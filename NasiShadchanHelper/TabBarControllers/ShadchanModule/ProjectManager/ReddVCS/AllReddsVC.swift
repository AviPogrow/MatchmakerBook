//
//  AllReddsVC.swift
//  NasiShadchanHelper
//
//  Created by test on 2/22/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import Firebase

class AllReddsVC: UITableViewController {
    
    let reddsListRef = Database.database().reference().child("shadchanNasiMatchIdea")
    var reddsArray = [MatchIdea]()
    var allMatchArray = [MatchIdea]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Redds"
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Redd", style: .plain, target: self, action: #selector(handleAddRedd))

        
        fetchRedds()
        //fetchAllMatches()
        
    }
    
    @objc func  handleAddRedd(){
      
        let reddsDetailController = ReddsDetailVC()
        
        reddsDetailController.allMatchesArray = allMatchArray
        let newRedd = MatchIdea(boyID: "",
            girlID: "",
            dateCreated: "",
            boyFirstName: "",
            boyLastName: "",
            girlFirstName: "",
        girlLastName: "",
        girlImageDownloadString: "", girlResumeDownlaodString: "", boySendResumeEmail: "",
        boySendResumeText: "",
        boyCell: "",
        boyPhotoImageURL: "",
        currentStage: "",
        timeStampForIdea: "",
        timeStampForRedd: "",
        timeStampForFirstDate: "",
        timeStampForSecondDate: "",
        timeStampForThirdDate: "",
        timeStampForFourthDate: "",
                                dateOfFirstDate: "",
        dateOfSecondDate: "",
        dateOfThirdDate: "", dateOfFourthDate: "")
        reddsDetailController.selectedRedd = newRedd
        self.navigationController?.pushViewController(reddsDetailController, animated: true)
    }
    
    func fetchAllMatches() {
        let matchListRef = Database.database().reference().child("shadchanNasiMatchIdea")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        matchListRef.observe(.value, with: { snapshot in
            var tempMatchArray: [MatchIdea] = []
            for child in snapshot.children {
            let snapshot = child as? DataSnapshot
             let match = MatchIdea(snapshot: snapshot!)
                tempMatchArray.append(match)
            }
            self.allMatchArray = tempMatchArray
        })
            
        
    }
    
    func fetchRedds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let myReddsListRef = reddsListRef.child(uid)
        
        myReddsListRef.observe(.value, with: { snapshot in
            var reddsArray: [MatchIdea] = []
            var allMatchesArry:[MatchIdea] = []
            
            for child in snapshot.children {
            let snapshot = child as? DataSnapshot
             let redd = MatchIdea(snapshot: snapshot!)
                allMatchesArry.append(redd)
                if redd.currentStage == "redd" {
                reddsArray.append(redd)
                }
        }
            self.allMatchArray = allMatchesArry
            self.reddsArray = reddsArray
            print(self.reddsArray.description)
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reddsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReddCell", for: indexPath)

        let currentRedd = reddsArray[indexPath.row]
        let boysName = currentRedd.boyFirstName + " " + currentRedd.boyLastName
        let girlsName = currentRedd.girlFirstName + " " + currentRedd.girlLastName
        let rowNumb = "\(indexPath.row + 1)"
        cell.textLabel?.text = rowNumb + ": " + boysName + " " + girlsName
        cell.textLabel?.font = .boldSystemFont(ofSize: 20.0)
        
        
        cell.detailTextLabel?.textColor = .systemPink
        cell.detailTextLabel?.text = "Stage: " + currentRedd.currentStage
        cell.detailTextLabel?.font = .systemFont(ofSize: 20.0)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
    
    
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentRedd = reddsArray[indexPath.row]
        //let reddsDetailController = storyboard!.instantiateViewController(withIdentifier: "ReddsDetailVC") as! ReddsDetailVC
        
        let reddsDetailController = ReddsDetailVC()
        reddsDetailController.selectedRedd = currentRedd
        
        self.navigationController?.pushViewController(reddsDetailController, animated: true)
    }


}
