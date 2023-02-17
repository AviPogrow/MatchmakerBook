//
//  AllBoysViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 12/31/21.
//  Copyright © 2021 user. All rights reserved.
//

import UIKit
import Firebase

class AllBoysViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    
    // MARK: Properties
    var selectedBoysArray: [NasiBoy] = []
    
    var shadchanBoysArrayAll: [NasiBoy] = []
    var shadchanBoysArrayFTL: [NasiBoy] = []
    var shadchanBoysArrayPTL: [NasiBoy] = []
    var shadchanBoysArrayCollegeWorking:[NasiBoy] = []
    var engaged: [NasiBoy] = []
    
    let boysListRef  = Database.database().reference().child("NasiBoysList")
    
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAdd))
        
        tableView.delegate = self
        tableView.dataSource = self
        setUpSegmentControlApperance()
        
        fetchAllBoys()
        //fetchAndCreateBoysArray()
    }
    
    @objc func handleAdd() {
        let AddEditController = AddEditBoyViewController()
        
        navigationController?.pushViewController(AddEditController, animated: true)
    }
    
    func fetchAllBoys() {
    
        guard let myId = UserInfo.curentUser?.id else {return}
        let currentBoysListRef = boysListRef.child(myId)
        
        currentBoysListRef.observe(.value, with: { snapshot in
            var boysArray: [NasiBoy] = []
            var engagedBoysArray: [NasiBoy] = []
            
            for child in snapshot.children {
            let snapshot = child as? DataSnapshot
             let nasiBoy = NasiBoy(snapshot: snapshot!)
                if nasiBoy.status == "available" {
                boysArray.append(nasiBoy)
                }
                else if nasiBoy.status == "engaged" {
                engagedBoysArray.append(nasiBoy)
                }
             }
            
            self.engaged = engagedBoysArray
            self.selectedBoysArray = boysArray
            
            self.tableView.reloadData()
           
            })
    }
    
    /*
    func handleItemRemoved() {
    guard let myId = UserInfo.curentUser?.id else {return}
    let currentBoysListRef = boysListRef.child(myId)
    
    currentBoysListRef.observe(.childRemoved, with: { snapshot in
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    })
    
    }
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAndCreateBoysArray()
        
    }
    
    
    func figureOutTheRightArray() {
        
        currentIndex = segmentControl.selectedSegmentIndex
        
        if currentIndex == 0 {
            self.selectedBoysArray = shadchanBoysArrayAll
        }
    else if currentIndex == 1 {
        self.selectedBoysArray = shadchanBoysArrayFTL
    } else if currentIndex == 2 {
        self.selectedBoysArray = shadchanBoysArrayPTL
    } else if currentIndex == 3  {
        self.selectedBoysArray = shadchanBoysArrayCollegeWorking
    } else if currentIndex == 4 {
        self.selectedBoysArray = engaged
    }
    
}

    
    func fetchAndCreateBoysArray() {

      let boysListRef  = Database.database().reference().child("NasiBoysList")
        
        guard let myId = UserInfo.curentUser?.id else {return}
        
        let currentUserBoysListRef = boysListRef.child(myId)
      
        currentUserBoysListRef.observe(.value, with: { snapshot in
        
         var boysArray: [NasiBoy] = []
            var engagedBoysArray: [NasiBoy] = []
            
            for child in snapshot.children {
              
            let snapshot = child as? DataSnapshot
            let nasiBoy = NasiBoy(snapshot: snapshot!)
            if nasiBoy.status == "available" {
            boysArray.append(nasiBoy)
            }
            else if nasiBoy.status == "engaged" {
            engagedBoysArray.append(nasiBoy)
            }
                        
          }
           
            // take localboys array and assign it
            // to instance var array
            //self.selectedBoysArray = boysArray
            
            // pass instance var array to
            // build separate arrays for each cateogry
            self.buildCategoriesArrays(boysArray: boysArray)
            self.engaged = engagedBoysArray
            // use the selected index to figure our which
            // array should be assigned to the instance var
            // array
            self.figureOutTheRightArray()
           
          
        })
       
        self.tableView.reloadData()
        
    }
    
    func buildCategoriesArrays(boysArray: [NasiBoy]) {
        
        self.shadchanBoysArrayAll = boysArray
        
        //if boy in boysArray is "engaged" "yes" {
       // then put him in a separate engaged array
        // also filter him out from the other arrays
   // }
        
      
        self.shadchanBoysArrayAll.sort(by: { (boy1, boy2) -> Bool in
         return boy1.boyLastName < boy2.boyLastName
        })
        
        self.shadchanBoysArrayFTL =  boysArray.filter { nasiBoy in
            nasiBoy.categories.contains("FTL - 1-3")  || nasiBoy.categories.contains("FTL - 3-5") || nasiBoy.categories.contains("FTL - 5-7") || nasiBoy.categories.contains("FTL - 7+")         }
        
        self.shadchanBoysArrayFTL.sort(by: { (boy1, boy2) -> Bool in
         return boy1.dateLastUpdate > boy2.dateLastUpdate
        })
        
        
        self.shadchanBoysArrayPTL = boysArray.filter { nasiBoy in
            nasiBoy.categories.contains("PTL - School")  || nasiBoy.categories.contains("PTL - Working")
        }
        
        self.shadchanBoysArrayPTL.sort(by: { (boy1, boy2) -> Bool in
         return boy1.dateLastUpdate > boy2.dateLastUpdate
        })
        
        
        
        self.shadchanBoysArrayCollegeWorking = boysArray.filter { nasiBoy in
            nasiBoy.categories.contains("FTW/College-Yeshiva Style")  || nasiBoy.categories.contains("FTW/College-Not Yeshiva Style")
            
        }
        
        self.shadchanBoysArrayCollegeWorking.sort(by: { (boy1, boy2) -> Bool in
         return boy1.dateLastUpdate > boy2.dateLastUpdate
        })
       
        self.engaged.sort(by: { (boy1, boy2) -> Bool in
         return boy1.dateLastUpdate > boy2.dateLastUpdate
        })
        
        
        
    }
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
                
        if sender.selectedSegmentIndex == 0 {
            self.selectedBoysArray = shadchanBoysArrayAll
        }
        if sender.selectedSegmentIndex == 1 {
            self.selectedBoysArray = shadchanBoysArrayFTL
        } else if sender.selectedSegmentIndex == 2 {
            self.selectedBoysArray = shadchanBoysArrayPTL
        } else if sender.selectedSegmentIndex == 3  {
            self.selectedBoysArray = shadchanBoysArrayCollegeWorking
        } else if sender.selectedSegmentIndex == 4 {
            self.selectedBoysArray = engaged
        }
        
        
        
        self.tableView.reloadData()
    }
    
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return selectedBoysArray.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        let nasiBoy = selectedBoysArray[indexPath.row]
        
        
        // get the dob string
        let dobString = nasiBoy.dobIntervalString
        let dateFormatter = DateFormatter()
        // Set Date Format
         dateFormatter.dateFormat = "YY/MM/dd"
        
        var ageString = "\(0)"
        if  let date = dateFormatter.date(from: dobString) {
        let age = try self.calculateAgeFrom(dob: date)
        ageString  = "\(age)"
            
        }
    
        //get the last update as string of seconds
        let lastUpdate = nasiBoy.dateLastUpdate
        let timeAgoDisplayString = calcTimeAgoFromIntSeconds(seconds: lastUpdate)
        

        cell.textLabel?.text = nasiBoy.boyLastName + " " +
        nasiBoy.boyFirstName //+ " " + "\(timeAgoDisplayString)"
        cell.detailTextLabel?.text = "Height: " + nasiBoy.boyHeight + " " + "  Age: " + ageString  + " yrs "  //+ //timeAgoDisplayString
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func calcTimeAgoFromIntSeconds(seconds:Int ) -> String {
        
        let secondsAgo = seconds

        if secondsAgo >= 86400 * 2 {
            return "\(((secondsAgo / 60) / 60) / 24) days ago"
        } else if secondsAgo >= 86400 {
            return "\(((secondsAgo / 60) / 60) / 24) day ago"
        } else if secondsAgo > 7200 {
            return "\((secondsAgo / 60) / 60) hours ago"
        } else if secondsAgo >= 3600 {
            return "\((secondsAgo / 60) / 60) Hour ago"
        } else if secondsAgo < 60 {
            return "\(secondsAgo) seconds ago"
        } else if secondsAgo > 119 {
            return "\(secondsAgo / 60) minutes ago"
        }

        return "\(secondsAgo / 60) minute ago"
    }
        

    
    @IBAction func addBoyTapped(_ sender: Any) {
        //let controller = storyboard!.instantiateViewController(withIdentifier: "AddEditBoyViewController") as! AddEditBoyViewController

       // navigationController?.pushViewController(controller, animated: true)

        
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddEditBoyViewController") as! AddEditBoyViewController

        var currentNasiBoy: NasiBoy!
    
        currentNasiBoy = selectedBoysArray[indexPath.row]
       controller.selectedNasiBoy = currentNasiBoy
        navigationController?.pushViewController(controller, animated: true)
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
   
    

}

/*
extension TimeInterval {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(self)

        if secondsAgo >= 86400 * 2 {
            return "\(((secondsAgo / 60) / 60) / 24) days ago"
        } else if secondsAgo >= 86400 {
            return "\(((secondsAgo / 60) / 60) / 24) day ago"
        } else if secondsAgo > 7200 {
            return "\((secondsAgo / 60) / 60) hours ago"
        } else if secondsAgo >= 3600 {
            return "\((secondsAgo / 60) / 60) Hour ago"
        } else if secondsAgo < 60 {
            return "\(secondsAgo) seconds ago"
        } else if secondsAgo > 119 {
            return "\(secondsAgo / 60) minutes ago"
        }

        return "\(secondsAgo / 60) minute ago"
    }
}
*/
extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
        
    }
}


