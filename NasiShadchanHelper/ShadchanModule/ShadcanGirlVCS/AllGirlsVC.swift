//
//  AllGirlsVC.swift
//  NasiShadchanHelper
//
//  Created by test on 11/14/22.
//  Copyright © 2022 user. All rights reserved.
//

import UIKit
import Firebase


class AllGirlsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // MARK: Properties
    var selectedGirlsArray: [ShadchanGirl] = []
    
    var shadchanGirlsArrayAll: [ShadchanGirl] = []
    var shadchanGirlsArrayFTL: [ShadchanGirl] = []
    var shadchanGirlsArrayPTL: [ShadchanGirl] = []
    var shadchanGirlsArrayCollegeWorking:[ShadchanGirl] = []
    var engaged: [ShadchanGirl] = []
    let shadchanGirlsListRef  = Database.database().reference().child("PrivateGirlsList")

    var currentIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAdd))
    
        
        
        tableView.delegate = self
        tableView.dataSource = self
        setUpSegmentControlApperance()
        fetchAllGirls()

      
    }
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        
        
        if sender.selectedSegmentIndex == 0 {
            self.selectedGirlsArray = shadchanGirlsArrayAll
        }
        if sender.selectedSegmentIndex == 1 {
            self.selectedGirlsArray = shadchanGirlsArrayFTL
        } else if sender.selectedSegmentIndex == 2 {
            self.selectedGirlsArray = shadchanGirlsArrayPTL
        } else if sender.selectedSegmentIndex == 3  {
            self.selectedGirlsArray = shadchanGirlsArrayCollegeWorking
        }
        self.tableView.reloadData()
    }
    
    func figureOutTheRightArray() {
        
        currentIndex = segmentControl.selectedSegmentIndex
        
        if currentIndex == 0 {
            self.selectedGirlsArray = shadchanGirlsArrayAll
        }
    else if currentIndex == 1 {
        self.selectedGirlsArray = shadchanGirlsArrayFTL
    } else if currentIndex == 2 {
        self.selectedGirlsArray = shadchanGirlsArrayPTL
    } else if currentIndex == 3  {
        self.selectedGirlsArray = shadchanGirlsArrayCollegeWorking
    } else if currentIndex == 4 {
        self.selectedGirlsArray = engaged
    }
    
}
    
    
    
    
    func buildCategoriesArrays(girlsArray: [ShadchanGirl]) {
        
        self.shadchanGirlsArrayAll = girlsArray
        
        self.shadchanGirlsArrayAll.sort(by: { (girl1, girl2) -> Bool in
         return girl1.girlLastName < girl2.girlLastName
        })
        
        self.shadchanGirlsArrayFTL =  girlsArray.filter { shadchanGirl in
            shadchanGirl.categories.contains("FTL - 1-3")  || shadchanGirl.categories.contains("FTL - 3-5") || shadchanGirl.categories.contains("FTL - 5-7") || shadchanGirl.categories.contains("FTL - 7+")
        }
        
        self.shadchanGirlsArrayFTL.sort(by: { (girl1, girl2) -> Bool in
         return girl1.dateLastUpdate > girl2.dateLastUpdate
        })
        
        
        self.shadchanGirlsArrayPTL = girlsArray.filter { shadchanGirl in
            shadchanGirl.categories.contains("PTL - School")  || shadchanGirl.categories.contains("PTL - Working")
        }
        
        self.shadchanGirlsArrayPTL.sort(by: { (girl1, girl2) -> Bool in
         return girl1.dateLastUpdate > girl2.dateLastUpdate
        })
        
        
        
        self.shadchanGirlsArrayCollegeWorking = girlsArray.filter { shadchanGirl in
            shadchanGirl.categories.contains("FTW/College-Yeshiva Style")  || shadchanGirl.categories.contains("FTW/College-Not Yeshiva Style")
            
        }
        
        self.shadchanGirlsArrayCollegeWorking.sort(by: { (girl1, girl2) -> Bool in
         return girl1.dateLastUpdate > girl2.dateLastUpdate
        })
    }
  

    
    @objc func handleAdd() {
        let AddEditController = AddEditGirlViewController()
        
        navigationController?.pushViewController(AddEditController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    
        let controller =  AddEditGirlViewController()

        var currentGirl: ShadchanGirl!
    
        currentGirl = selectedGirlsArray[indexPath.row]
       controller.selectedShadchanGirl = currentGirl
        navigationController?.pushViewController(controller, animated: true)
        }
    
    
    
    func fetchAllGirls() {
        guard let myId = UserInfo.curentUser?.id else {return}
        let currentGirlsListRef = shadchanGirlsListRef.child(myId)
        
        currentGirlsListRef.observe(.value, with: { snapshot in
            var girlsArray: [ShadchanGirl] = []
            for child in snapshot.children {
            let snapshot = child as? DataSnapshot
             let shadchanGirl = ShadchanGirl(snapshot: snapshot!)
                girlsArray.append(shadchanGirl)
             }
           
             self.selectedGirlsArray = girlsArray
             self.tableView.reloadData()
            })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAndCreateGirlsArray()
    }
    
    func fetchAndCreateGirlsArray() {

      let girlsListRef  = Database.database().reference().child("PrivateGirlsList")
        
        guard let myId = UserInfo.curentUser?.id else {return}
        
        let currentUserGirlsListRef = girlsListRef.child(myId)
      
        currentUserGirlsListRef.observe(.value, with: { snapshot in
        
         var girlsArray: [ShadchanGirl] = []
            var engagedGirlsArray: [ShadchanGirl] = []
            
            for child in snapshot.children {
              
            let snapshot = child as? DataSnapshot
            let shadchanGirl = ShadchanGirl(snapshot: snapshot!)
            if shadchanGirl.status == "available" {
            girlsArray.append(shadchanGirl)
            }
            else if shadchanGirl.status == "engaged" {
            engagedGirlsArray.append(shadchanGirl)
            }
                        
          }
           
            // take localboys array and assign it
            // to instance var array
            //self.selectedBoysArray = boysArray
            
            // pass instance var array to
            // build separate arrays for each cateogry
            self.buildCategoriesArrays(girlsArray: girlsArray)
            self.engaged = engagedGirlsArray
            // use the selected index to figure our which
            // array should be assigned to the instance var
            // array
            self.figureOutTheRightArray()
           
          
        })
       
        self.tableView.reloadData()
        
    }
    
    
    
    
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
    
    func calculateAgeFrom(dob: Date) -> Double {
        
        let dateOfBirth = dob
        
      
        
        // get today as a date object and compare
        let today = Date()
        
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year,.month, .day], from: dateOfBirth, to: today)
        
        let ageYears = components.year
       
        
        let decimal =  Double(components.month!) / Double(12)
        
        
        let compositeNumb = Double(ageYears!) + decimal
        
        let  roundedNumb =    Double(compositeNumb).rounded(toPlaces: 1)
        return roundedNumb
        
    }
    

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectedGirlsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "ShadchanGirlCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let shadchanGirl = selectedGirlsArray[indexPath.row]
        cell.textLabel?.text = shadchanGirl.girlFirstName + " " +  shadchanGirl.girlLastName
        
        
        // get the dob string
        let dobString = shadchanGirl.dobIntervalString
        let dateFormatter = DateFormatter()
        // Set Date Format
         dateFormatter.dateFormat = "YY/MM/dd"
        
        var ageString = "\(0)"
        if  let date = dateFormatter.date(from: dobString) {
        let age = try self.calculateAgeFrom(dob: date)
        ageString  = "\(age)"
            
        }
        
        cell.detailTextLabel?.text = "Height: " + shadchanGirl.girlHeight + " " + "  Age: " + ageString  + " yrs "  //+ //timeAgoDisplayString
        
        
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    

   
   

}
