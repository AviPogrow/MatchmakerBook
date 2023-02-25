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

    var secondDatesArray = [AppFirstDate]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSecondDates()
        
    }
    
    func fetchSecondDates() {
        
        let secondDatesListRef  = Database.database().reference().child("AppSecondDates")
            guard let uid = Auth.auth().currentUser?.uid else { return }
    let mySecondDatesListRef = secondDatesListRef.child(uid)
        secondDatesListRef.observe(.value, with: { snapshot in
                var secondDatesArray: [AppFirstDate] = []
                
                for child in snapshot.children {
                let snapshot = child as? DataSnapshot
                 let appFirstDate = AppFirstDate(snapshot: snapshot!)
                    secondDatesArray.append(appFirstDate)
            }
                self.secondDatesArray = secondDatesArray
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
        cell.textLabel?.text = currentDate.boyLastName + " " +  currentDate.girlLastName

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
   
    
}
