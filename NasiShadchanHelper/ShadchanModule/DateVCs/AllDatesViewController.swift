//
//  AllDatesViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 1/22/22.
//  Copyright © 2022 user. All rights reserved.
//


import UIKit
import Firebase

class AllDatesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // MARK: Properties
    var selectedDatesArray: [NasiDate] = []
    
    var nasiDatesArrayAll: [NasiDate] = []
    var nasiDatesArrayIdea: [NasiDate] = []
    var nasiDatesArrayActive: [NasiDate] = []
    var nasiDatesArrayFinished: [NasiDate] = []
    var nasiDatesArrayEngaged: [NasiDate] = []
    
    
   let datesListRef  = Database.database().reference().child("NasiDatesList")
    
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.dataSource = self
        tableView.delegate = self
        setUpSegmentControlApperance()
        
        fetchAllDates()
    }
    
    func fetchAllDates() {
        
        guard let myId = UserInfo.curentUser?.id else {return}
        let currentUserDatesListRef = datesListRef.child(myId)

        currentUserDatesListRef.observe(.value, with: { snapshot in
        
        var datesArray: [NasiDate] = []
            
            for child in snapshot.children {
              
            let snapshot = child as? DataSnapshot
             let nasiDate = NasiDate(snapshot: snapshot!)
              datesArray.append(nasiDate)
           }
            self.selectedDatesArray = datesArray
            self.tableView.reloadData()
        })
     }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        
     fetchAndCreateAllDatesArrays()
    }
    
  

    func figureOutTheRightArray() {
        
     currentIndex = segmentControl.selectedSegmentIndex
        
     if currentIndex == 0 {
       self.selectedDatesArray = nasiDatesArrayAll
     }
      else if currentIndex == 1 {
        self.selectedDatesArray = nasiDatesArrayIdea
    } else if currentIndex == 2 {
        self.selectedDatesArray = nasiDatesArrayActive
    } else if currentIndex == 3  {
        self.selectedDatesArray = nasiDatesArrayEngaged
    } else if currentIndex == 4 {
        self.selectedDatesArray = nasiDatesArrayFinished
    }
    
}
    
    // when segment is tapped array gets set to proper sub array
    // and table view is reloaded to show new list
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            self.selectedDatesArray = nasiDatesArrayAll
        }
        if sender.selectedSegmentIndex == 1 {
            self.selectedDatesArray = nasiDatesArrayIdea
        } else if sender.selectedSegmentIndex == 2 {
            self.selectedDatesArray = nasiDatesArrayActive
        } else if sender.selectedSegmentIndex == 3  {
            self.selectedDatesArray = nasiDatesArrayEngaged
        } else if sender.selectedSegmentIndex == 4 {
            self.selectedDatesArray = nasiDatesArrayFinished
            
        }
        self.tableView.reloadData()
    }
    
    func fetchAndCreateAllDatesArrays() {

        guard let myId = UserInfo.curentUser?.id else {return}

        let currentUserDatesListRef = datesListRef.child(myId)
        
        currentUserDatesListRef.observe(.value, with: { snapshot in
        
        var datesArray: [NasiDate] = []
            
            for child in snapshot.children {
              
            let snapshot = child as? DataSnapshot
             let nasiDate = NasiDate(snapshot: snapshot!)
              datesArray.append(nasiDate)
            }
        
            self.selectedDatesArray = datesArray
            self.buildCategoriesArrays(datesArray: datesArray)
            self.figureOutTheRightArray()
        })
        self.tableView.reloadData()
    }
    
    func buildCategoriesArrays(datesArray: [NasiDate]) {
        
        self.nasiDatesArrayAll = datesArray
        self.nasiDatesArrayAll.sort(by: { (date1, date2) -> Bool in
            
            return date1.dateLastUpdate > date2.dateLastUpdate
        })
        
        self.nasiDatesArrayIdea =  datesArray.filter { nasiDate in
          nasiDate.datingStatus == "Idea"
        }
        
        self.nasiDatesArrayIdea.sort(by: { (date1, date2) -> Bool in
            
            return date1.dateLastUpdate > date2.dateLastUpdate
        })
        
       self.nasiDatesArrayActive =  datesArray.filter { nasiDate in
                 nasiDate.datingStatus == "Active"
            }
        
        self.nasiDatesArrayActive.sort(by: { (date1, date2) -> Bool in
            
            return date1.dateLastUpdate > date2.dateLastUpdate
        })
             
         self.nasiDatesArrayFinished =  datesArray.filter { nasiDate in
                 nasiDate.datingStatus == "Finished"
         }
        
        self.nasiDatesArrayFinished.sort(by: { (date1, date2) -> Bool in
            
            return date1.dateLastUpdate > date2.dateLastUpdate
        })
             
         self.nasiDatesArrayEngaged =  datesArray.filter { nasiDate in
                     nasiDate.datingStatus == "Engaged"
         }
        
        self.nasiDatesArrayEngaged.sort(by: { (date1, date2) -> Bool in
            
            return date1.dateLastUpdate > date2.dateLastUpdate
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectedDatesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "cellID"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let nasiDate = selectedDatesArray[indexPath.row]
        cell.textLabel?.text = nasiDate.boyFullName + " & " +  nasiDate.girlFullName
        
        cell.detailTextLabel?.textColor = UIColor.darkGray
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.detailTextLabel?.text = "Dating Status: " +  "\(nasiDate.datingStatus)  "
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddEditDatesViewController") as! AddEditDatesViewController

        var currentNasiDate: NasiDate!
    
        currentNasiDate = selectedDatesArray[indexPath.row]
        
        controller.selectedNasiDate = currentNasiDate
        navigationController?.pushViewController(controller, animated: true)
        }
    
    /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
          let currentDate = selectedDatesArray[indexPath.row]
          currentDate.ref?.removeValue()
          tableView.reloadData()
      }
    }
    */
    func setUpSegmentControlApperance() {
        segmentControl.selectedSegmentTintColor = Constant.AppColor.colorAppTheme
        
        let titleTextAttributesSelected = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                           NSAttributedString.Key.font: Constant.AppFontHelper.defaultSemiboldFontWithSize(size: 16)]
        segmentControl.setTitleTextAttributes(titleTextAttributesSelected, for:.selected)
        
        let titleTextAttributesDefault = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                          NSAttributedString.Key.font: Constant.AppFontHelper.defaultRegularFontWithSize(size: 16)]
        segmentControl.setTitleTextAttributes(titleTextAttributesDefault, for:.normal)
        
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
    }
}



