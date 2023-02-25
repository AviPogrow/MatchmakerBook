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
    
    let reddsListRef = Database.database().reference().child("ShadchanReddsList")
    var reddsArray = [ShadchanRedd]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Redds"
        fetchRedds()
        
    }
    
    func fetchRedds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let myReddsListRef = reddsListRef.child(uid)
        
        myReddsListRef.observe(.value, with: { snapshot in
            var reddsArray: [ShadchanRedd] = []
            
            for child in snapshot.children {
            let snapshot = child as? DataSnapshot
             let redd = ShadchanRedd(snapshot: snapshot!)
            reddsArray.append(redd)
        }
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
        // #warning Incomplete implementation, return the number of rows
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
        
        let colors = [UIColor.red, UIColor.gray,UIColor.green, UIColor.blue]
        let reddResults = ["waiting for boy","boy said no","started dating","waiting for girl"]
       cell.detailTextLabel?.text = "Status: N/A " //+ reddResults[indexPath.row] ?? "N/A"
        //cell.detailTextLabel?.textColor = colors[indexPath.row]
        cell.detailTextLabel?.font = .systemFont(ofSize: 20.0)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentRedd = reddsArray[indexPath.row]
        let reddsDetailController = storyboard!.instantiateViewController(withIdentifier: "ReddsDetailVC") as! ReddsDetailVC
        reddsDetailController.selectedRedd = currentRedd
        
        self.navigationController?.pushViewController(reddsDetailController, animated: true)
    }


}
