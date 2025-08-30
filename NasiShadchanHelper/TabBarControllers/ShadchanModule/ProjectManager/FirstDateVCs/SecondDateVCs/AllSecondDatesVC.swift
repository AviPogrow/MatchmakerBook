//
//  AllSecondDatesVC.swift
//  NasiShadchanHelper
//
//  Created by test on 2/23/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import Firebase

class AllSecondDatesVC: UITableViewController {

    var secondDatesArray =  [MatchIdea]()
    let secondDatesListRef = Database.database().reference().child("shadchanNasiMatchIdea")
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Second Dates"
        fetchSecondDates()
        
    }
    
    func fetchSecondDates() {
        
    let secondDatesListRef = Database.database().reference().child("shadchanNasiMatchIdea")
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let mySecondDatesListRef  = secondDatesListRef.child(uid)
        mySecondDatesListRef.observe(.value, with: { snapshot in
    
        var tempSecondDatesArray: [MatchIdea] = []
            for child in snapshot.children {
            let snapshot = child as? DataSnapshot
             let secondDate = MatchIdea(snapshot: snapshot!)
                if secondDate.currentStage == "secondDate" {
                tempSecondDatesArray.append(secondDate)
                }
            }
                self.secondDatesArray = tempSecondDatesArray
                print(self.secondDatesArray.description)
                self.tableView.reloadData()
            })
            
        }
        
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return secondDatesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SecondDates", for: indexPath)

        let currentDate = secondDatesArray[indexPath.row]
        cell.textLabel?.text = currentDate.boyFirstName + " " +
        currentDate.boyLastName + " " + currentDate.girlFirstName + " " +  currentDate.girlLastName
        cell.textLabel?.font = .boldSystemFont(ofSize: 20)
        cell.detailTextLabel?.font = .systemFont(ofSize: 20)
        cell.detailTextLabel?.textColor = .systemPink
        cell.detailTextLabel?.text = currentDate.currentStage

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let secondDateDetailController = SecondDatesDetailVC()
        let currentDate = secondDatesArray[indexPath.row]
        secondDateDetailController.selectedSecondDate = currentDate
        self.navigationController?.pushViewController(secondDateDetailController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
   
    
}
