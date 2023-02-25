//
//  ShadchanIdeasVC.swift
//  NasiShadchanHelper
//
//  Created by test on 2/20/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import Firebase

class ShadchanIdeasVC: UITableViewController {

    let ideasListRef  = Database.database().reference().child("shadchanNasiMatchIdea")
    var ideasArray =  [MatchIdea]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles
        navigationItem.title = "Ideas"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Idea", style: .plain, target: self, action: #selector(handleAdd))

        fetchIdeas()
    }
    
    func fetchIdeas() {
        guard let myId = UserInfo.curentUser?.id else {return}
        let currentUserIdeasListRef = ideasListRef.child(myId)
        
        currentUserIdeasListRef.observe(.value, with: { snapshot in
            var matchIdeasArray: [MatchIdea] = []
            
            for child in snapshot.children {
            let snapshot = child as? DataSnapshot
             let matchIdea = MatchIdea(snapshot: snapshot!)
            matchIdeasArray.append(matchIdea)
        }
            self.ideasArray = matchIdeasArray
            print(self.ideasArray.description)
            self.tableView.reloadData()
        })
    }
        
    
    @objc func handleAdd() {
        let ideasDetailVC = storyboard!.instantiateViewController(withIdentifier: "AllBoysViewController") as! AllBoysViewController
        self.navigationController?.pushViewController(ideasDetailVC, animated: true)
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.ideasArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchIdeaCell", for: indexPath)

        let rowNumb = "\(indexPath.row + 1)"
        let currentIdea =  self.ideasArray[indexPath.row]
        cell.textLabel?.font = .boldSystemFont(ofSize: 20.0)
        cell.textLabel?.text =  rowNumb + ": " + currentIdea.girlFirstName + " " + currentIdea.girlLastName + " & " + currentIdea.boyFirstName + " " + currentIdea.boyLastName
        
        let statuses = ["ready to redd","ready to redd","need to discuss","","",""]
        let colors = [UIColor.green, UIColor.green, UIColor.yellow, UIColor.gray, UIColor.red,.red,.red,.gray]
        //cell.detailTextLabel?.font = .systemFont(ofSize: 20.0)
        
       // cell.detailTextLabel?.textColor = colors[indexPath.row]
        cell.detailTextLabel?.text = "Status: N/A"
        //+ statuses[indexPath.row] ?? "N/A"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMatchIdea = ideasArray[indexPath.row]
        
        let ideaDetailsController = storyboard!.instantiateViewController(withIdentifier: "MatchIdeaDetailsViewController") as! MatchIdeaDetailsViewController
        ideaDetailsController.selectedMatchIdea = selectedMatchIdea
        navigationController?.pushViewController(ideaDetailsController, animated: true)
    }
   

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

}
