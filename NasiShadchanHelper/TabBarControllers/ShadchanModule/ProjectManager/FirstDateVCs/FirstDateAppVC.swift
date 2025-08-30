//
//  AllAppDatesVC.swift
//  NasiShadchanHelper
//
//  Created by test on 2/22/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import Firebase


class FirstDateAppVC: UITableViewController {
    
    var firstDatesArray =  [MatchIdea]()
    
    let firstDatesListRef = Database.database().reference().child("shadchanNasiMatchIdea")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "First Dates"
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(handleAddFirstDate))

        
        fetchFirstDates()
        
    }
    
    @objc func handleAddFirstDate() {
        let firstDateController = FirstDateDetailVC()
        navigationController?.pushViewController(firstDateController, animated: true)
    }
    
    func fetchFirstDates() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let myFirstDatesListRef  = firstDatesListRef.child(uid)
        myFirstDatesListRef.observe(.value, with: { snapshot in
            var firstDatesArray: [MatchIdea] = []
            
            for child in snapshot.children {
            let snapshot = child as? DataSnapshot
             let firstDate = MatchIdea(snapshot: snapshot!)
                if firstDate.currentStage == "firstDate" {
                firstDatesArray.append(firstDate)
                }
        }
            self.firstDatesArray = firstDatesArray
            print(self.firstDatesArray.description)
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
        return firstDatesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppDateCell", for: indexPath)

        let currentAppDate = firstDatesArray[indexPath.row]
        cell.textLabel?.text = currentAppDate.boyFirstName + " " + currentAppDate.boyLastName + " " + currentAppDate.girlFirstName + " " + currentAppDate.girlLastName
        cell.detailTextLabel?.textColor = .systemPink
        cell.textLabel?.font = .boldSystemFont(ofSize: 20.0)
        cell.detailTextLabel?.font = .systemFont(ofSize: 20.0)
        cell.detailTextLabel?.text = "Status: " + currentAppDate.currentStage
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController =  FirstDateDetailVC()
        let currentDate = firstDatesArray[indexPath.row]
        detailController.selectedFirstDate = currentDate
        detailController.firstDatesArray = firstDatesArray
        navigationController?.pushViewController(detailController, animated: true)
    }
  

}
