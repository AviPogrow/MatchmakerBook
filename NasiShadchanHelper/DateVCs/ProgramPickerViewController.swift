//
//  ProgramPickerViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 1/29/22.
//  Copyright © 2022 user. All rights reserved.
//

import UIKit

class ProgramPickerViewController: UITableViewController {

    var selectedProgramName = "N/A"
     let programs = [
       "N/A",
       "Nasi List",
       "AY",
       "Sefardim"]
    
     var selectedIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0..<programs.count {
             if programs[i] == selectedProgramName {
               selectedIndexPath = IndexPath(row: i, section: 0)
       break
       }
    }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView,
           numberOfRowsInSection section: Int) -> Int {
       return programs.count
     }

    override func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) ->
                   UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                             withIdentifier: "Cell",
                                        for: indexPath)
        let programName = programs[indexPath.row]
        cell.textLabel!.text = programName
        if programName == selectedProgramName {
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
    if segue.identifier == "PickedProgram" {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
          selectedProgramName = programs[indexPath.row]
        }
    }
        
    }
    
    
}
