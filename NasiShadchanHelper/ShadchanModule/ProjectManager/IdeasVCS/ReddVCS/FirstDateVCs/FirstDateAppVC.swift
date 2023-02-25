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
    
    var appFirstDatesArray =  [AppFirstDate]()
    var reddsArray = [ShadchanRedd]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAllFirstAppDates()
    navigationItem.title = "1st dates"

    }
    
    func fetchAllFirstAppDates() {
        let firstDatesListRef  = Database.database().reference().child("AppFirstDates")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let myFirstDatesListRef = firstDatesListRef.child(uid)
        
        myFirstDatesListRef.observe(.value, with: { snapshot in
            var firstDatesArray: [AppFirstDate] = []
            
            print("snapshot looks like \(snapshot.description)")
            
        
            for child in snapshot.children {
            let snapshot = child as? DataSnapshot
             let appFirstDate = AppFirstDate(snapshot: snapshot!)
                firstDatesArray.append(appFirstDate)
        }
            self.appFirstDatesArray = firstDatesArray
            print(self.appFirstDatesArray.description)
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
        return appFirstDatesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppDateCell", for: indexPath)

        let currentAppDate = appFirstDatesArray[indexPath.row]
        cell.textLabel?.text = currentAppDate.boyFirstName + " " + currentAppDate.boyLastName + " " + currentAppDate.girlFirstName + " " + currentAppDate.girlLastName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = storyboard!.instantiateViewController(withIdentifier: "FirstDateDetailVC") as! FirstDateDetailVC
        let currentAppDate = appFirstDatesArray[indexPath.row]
        detailController.selectedFirstDate = currentAppDate
        navigationController?.pushViewController(detailController, animated: true)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }

}
