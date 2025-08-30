//
//  DateNumberPIckerViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 1/29/22.
//  Copyright © 2022 user. All rights reserved.
//

import UIKit

class DateNumberPIckerViewController: UITableViewController {
    
    var selectedDateNumber = "0"
     let dateNumbers = [
       "0",
       "1",
       "2",
       "3",
       "4",
       "5",
       "6",
       "7",
       "8",
       "9",
       "10",
       "11",
       "12",
       "13",
       "14",
       "15",
       "16",
       "17",
       "18",
       "19",
       "20"
     ]
    
     var selectedIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0..<dateNumbers.count {
             if dateNumbers[i] == selectedDateNumber {
               selectedIndexPath = IndexPath(row: i, section: 0)
       break
       }
    }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView,
           numberOfRowsInSection section: Int) -> Int {
       return dateNumbers.count
     }
    

    override func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) ->
                   UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                             withIdentifier: "Cell",
                                        for: indexPath)
        let dateNumber = dateNumbers[indexPath.row]
        cell.textLabel!.text = dateNumber
        if dateNumber == selectedDateNumber {
          cell.accessoryType = .checkmark
    } else {
          cell.accessoryType = .none
        }
    return cell
                       
    }
    
    override func tableView(_ tableView: UITableView,
               didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
      if indexPath.row != selectedIndexPath.row {
        if let newCell = tableView.cellForRow(at: indexPath) {
          newCell.accessoryType = .checkmark
        }
        if let oldCell = tableView.cellForRow(
                         at: selectedIndexPath) {
          oldCell.accessoryType = .none
        }
        selectedIndexPath = indexPath
          
      }
  }
    
    
    // MARK: - Navigation
    override func prepare(
      for segue: UIStoryboardSegue,
      sender: Any?
    ){
    if segue.identifier == "PickedDateNumber" {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
          selectedDateNumber = dateNumbers[indexPath.row]
        }
    }
}
    

}

