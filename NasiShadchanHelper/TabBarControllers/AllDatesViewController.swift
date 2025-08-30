//
//  AllDatesViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 1/22/22.
//  Copyright © 2022 user. All rights reserved.
//


import UIKit
import Firebase

class AllDatesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var searchBar: UISearchBar!
    // MARK: Properties
    var allNasiGirlsList: [NasiGirl] = []
    var filteredNasiGirlsList: [NasiGirl] = []
    var nasiGirlsNamesStringArray: [String] = []
    var selectedDatesArray: [NasiDate] = []
    
    var nasiDatesArrayAll: [NasiDate] = []
    var nasiDatesArrayIdea: [NasiDate] = []
    var nasiDatesArrayActive: [NasiDate] = []
    var nasiDatesArrayFinished: [NasiDate] = []
    var nasiDatesArrayEngaged: [NasiDate] = []
    
    var boysToSelectArray:[NasiBoy] = []
    
    var shadchanGirlsToSelectArray:[Girl] = []
    var nasiGirlsToSelectArray: [Girl] = []
    
    var boysNamesAsStringsArray:[String] = []
    var girlsNamesAsStringsArray: [String] = []
    
    let datesListRef  = Database.database().reference().child("NasiDatesList")
    
    var currentIndex = 0
    
    var boyDatingHistories: [BoyDatingHistory] = [BoyDatingHistory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.placeholder = "Enter name"
        searchBar.searchTextField.textColor = .black
        searchBar.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.returnKeyType = .done
        
        tableView.dataSource = self
        tableView.delegate = self
        setUpSegmentControlApperance()
        fetchAllDates()
        
        fetchAndCreateBoysArray()
        fetchAndCreatePrivateGirlsArray()
        fetchAndCreateNasiGirlsArray()
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
                } else if nasiBoy.status == "engaged" {
                    engagedBoysArray.append(nasiBoy)
                }
            }
            self.boysToSelectArray = boysArray
        })
    }
    
    func fetchAndCreateNasiGirlsArray() {
        self.view.showLoadingIndicator()
         allNasiGirlsList.removeAll()
         let allNasiGirlsRef = Database.database().reference().child("NasiGirlsList")
          guard let myId = UserInfo.curentUser?.id else {return}
          allNasiGirlsRef.observe(.childAdded, with: { (snapshot) in
         
            let nasiGirl = NasiGirl(snapshot: snapshot)
              
              nasiGirl.lastName = nasiGirl.lastNameOfGirl
              nasiGirl.firstName = nasiGirl.firstNameOfGirl
              nasiGirl.dateOfBirthString = nasiGirl.dateOfBirth
              nasiGirl.ageString = String(nasiGirl.age)
              
              
         self.allNasiGirlsList.append(nasiGirl)
         self.allNasiGirlsList = self.allNasiGirlsList.sorted(by: { ($0.lastNameOfGirl) < ($1.lastNameOfGirl)
             })
             self.allNasiGirlsList = self.allNasiGirlsList.filter { (singleGirl) -> Bool in
             return singleGirl.category != Constant.CategoryTypeName.CategoryEngaged1
             }
             self.allNasiGirlsList = self.allNasiGirlsList.sorted(by: { ($0.lastNameOfGirl ) < ($1.lastNameOfGirl ) })
             DispatchQueue.main.async(execute: {
              self.view.hideLoadingIndicator()
              self.nasiGirlsToSelectArray = self.allNasiGirlsList
                 print("the nasiGirls array is \(self.allNasiGirlsList)")
                 
                 
              //self.collectionView.reloadData()
             })
          })
    }
    func fetchAndCreatePrivateGirlsArray() {
        let girlsListRef  = Database.database().reference().child("PrivateGirlsList")
        
        guard let myId = UserInfo.curentUser?.id else {return}
        let currentUserGirlsListRef = girlsListRef.child(myId)
        currentUserGirlsListRef.observe(.value, with: { snapshot in
            
            var girlsArray: [ShadchanGirl] = []
            var engagedGirlsArray: [ShadchanGirl] = []
            for child in snapshot.children {
                let snapshot = child as? DataSnapshot
                let shadchanGirl = ShadchanGirl(snapshot: snapshot!)
                shadchanGirl.lastName = shadchanGirl.girlLastName
                shadchanGirl.firstName = shadchanGirl.girlFirstName
                
            
                let dateString = shadchanGirl.dobIntervalString
                shadchanGirl.dateOfBirthString = dateString
                print("the value of dateString is: \(dateString)")
                
                
                
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YY/MM/dd"
                let backToDate = dateFormatter.date(from: dateString) ?? Date()
                
                let dateOfBirth = backToDate
                // get today as a date object and compare
                let today = Date()
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year,.month, .day], from: dateOfBirth, to: today)
                
                let ageYears = components.year
                let decimal =  Double(components.month!) / Double(12)
                let compositeNumb = Double(ageYears!) + decimal
                let  roundedNumb =    Double(compositeNumb).rounded(toPlaces: 1)
                let age = roundedNumb
                
                let ageAsString = "\(age)"
                shadchanGirl.ageString = ageAsString
                if shadchanGirl.status == "available" {
                    girlsArray.append(shadchanGirl)
                    
                } else if shadchanGirl.status == "engaged" {
                    engagedGirlsArray.append(shadchanGirl)
                }
            }
            self.shadchanGirlsToSelectArray = girlsArray
            
            
        })
    }
    
    func calculateAgeFrpm(dobString: String) -> Double {
        var age = 0.0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        let backToDate = dateFormatter.date(from: dobString)
        print(backToDate!)
        
                    
        let calculatedAge = calculateAgeFrom(dob: backToDate!)
        print(calculatedAge)
        return age
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
    
    
    func fetchAllDates() {
        
        guard let myId = UserInfo.curentUser?.id else {return}
        
        let currentUserDatesListRef = datesListRef.child(myId)
        
        currentUserDatesListRef.observe(.value, with: { snapshot in
            
            var datesArray: [NasiDate] = []
            
            for child in snapshot.children {
                
                let snapshot = child as? DataSnapshot
                let nasiDate = NasiDate(snapshot: snapshot!)
                
                
                
                
                datesArray.append(nasiDate)
                print(datesArray.debugDescription)
                
            }
            self.selectedDatesArray = datesArray
            
            
            self.createArrayOfDatingHistoryFromArrayOfNasiDates()
            self.tableView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if segmentControl.selectedSegmentIndex >  0 {
            searchBar.isHidden = true
        }
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
        if sender.selectedSegmentIndex >  0 {
            searchBar.isHidden = true
        }
        if sender.selectedSegmentIndex == 0 {
            searchBar.isHidden = false
        }
        
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
            
            //self.boyDatingHistories = self.convertDatesArrayToArrayOfBoyDatingHistories(nasiDatesArray: self.selectedDatesArray)
            
        })
        self.tableView.reloadData()
    }
    
    func buildCategoriesArrays(datesArray: [NasiDate]) {
        
        
        self.nasiDatesArrayAll = datesArray
        self.nasiDatesArrayAll.sort(by: { (date1, date2) -> Bool in
            
            return date1.boyLastName < date2.boyLastName
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchActive = false
        self.searchBar.endEditing(true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.selectedDatesArray = nasiDatesArrayAll
            
        } else {
            self.self.selectedDatesArray = self.selectedDatesArray.filter { (date) -> Bool in
                return
                date.boyLastName.lowercased().contains(searchText.lowercased()) ||
                date.boyFirstName.lowercased().contains(searchText.lowercased()) || date.girlLastName.lowercased().contains(searchText.lowercased()) ||
                date.girlFirstName.lowercased().contains(searchText.lowercased())
            }
        }
        self.tableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(selectedDatesArray.debugDescription)
        
        return selectedDatesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "cellID"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let nasiDate = selectedDatesArray[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.text =
        "\(indexPath.row + 1)" +  ": " + nasiDate.boyLastName + " " + nasiDate.boyFirstName + " & " + nasiDate.girlLastName + " "
        + nasiDate.girlFirstName
        
        cell.detailTextLabel?.textColor = UIColor.darkGray
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.detailTextLabel?.text = "Dating Status: " +  "\(nasiDate.datingStatus)  "
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddEditDateVC") as! AddEditDateVC
        
        controller.isEditingDate = true
        
        var currentNasiDate: NasiDate!
        currentNasiDate = selectedDatesArray[indexPath.row]
        
        
        controller.selectedNasiDate = currentNasiDate
        controller.boysToSelectArray = self.boysToSelectArray
        var  combinedArray = self.nasiGirlsToSelectArray + self.shadchanGirlsToSelectArray
        
        controller.girlsToSelectArray = combinedArray
        combinedArray.sort {$0.lastName < $1.lastName}
        controller.girlsToSelectArray = combinedArray
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func addDate(_ sender: Any) {
        addDateTapped()
    }
    func addDateTapped(){
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddEditDateVC") as! AddEditDateVC
        controller.isEditingDate == false
        controller.boysToSelectArray = self.boysToSelectArray
        
        var combinedGirlsArray: [Girl] = self.nasiGirlsToSelectArray + self.shadchanGirlsToSelectArray
        
        combinedGirlsArray.sort {$0.lastName < $1.lastName}
        controller.girlsToSelectArray = combinedGirlsArray
        let lastGirl = combinedGirlsArray.last!
        print("the last girl is \(lastGirl.lastName)")
        
        
        let nasiDate =     NasiDate(boyFirstName: "", boyLastName: "", boyFullName: "", boyKey: "", boyCellNumber: "", boyDobString: "",boysAge: "", dateNumber: "0", datingStatus: "Idea", girlFirstName: "", girlLastName: "", girlFullName: "", girlKey: "", girlDobString: "",girlAge: "", girlCellNumber: "", shadchanNotes: "", dateCreated: "", dateLastUpdate: 0, nasiProgram: "N/A")
        
        controller.selectedNasiDate = nasiDate
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
    
    
    // a model to describe one dating relationship
    // between one boy and one girl
    struct DatingRelationship {
        var boyId: String
        var boyName: String
        var girlName: String
        var boyCellNumber:String
        
        init(boyId: String, boyName: String, girlName: String,boyCellNumber:String) {
            self.boyId = boyId
            self.boyName = boyName
            self.girlName = girlName
            self.boyCellNumber = boyCellNumber
        }
        
        init?(dictionary: [String: Any]) {
            guard let boysName = dictionary["boyName"] as? String,
            let girlName = dictionary["girlName"] as? String,
            let boyCellNumber = dictionary["boyCellNumber"] as? String,
            let boyId = dictionary["boyId"] as? String
                    
            else {
                return nil
            }
            self.boyId = boyId
            self.boyName = boysName
            self.girlName = girlName
            self.boyCellNumber = boyCellNumber
        }
        
        func toDictionary() -> [String: Any] {
            return [
                "boyId": boyId,
                "boyName": boyName,
                "girlName": girlName,
                "boyCellNumber":boyCellNumber
            ]
            
        }
        
    }
    // a model to hold a list of "dating relationships"
     // where you may have one boy dating more than one girl
    struct BoyDatingHistory {
        var boyId: String
        var boysName: String
        var boysCellNumber: String
        var dates:[DatingRelationship]
        
        init(boyId: String, boysName: String,boysCellNumber: String,dates:[DatingRelationship]) {
            self.boyId = boyId
            self.boysName = boysName
            self.boysCellNumber = boysCellNumber
            self.dates = dates
            
        }
        
        // convert from dictionary
        init?(dictionary: [String: Any]) {
            guard let boyId = dictionary["boyId"] as? String,
                  let boysName = dictionary["boysName"] as? String,
                  let boysCellNumber = dictionary["boysCellNumber"] as? String,
                  let datingRelationshipsArray = dictionary["dates"] as? [[String: Any]]
                    
            else {
                return nil
            }
            self.boyId = boyId
            self.boysName = boysName
            self.boysCellNumber = boysCellNumber
            self.dates = datingRelationshipsArray.compactMap {DatingRelationship(dictionary: $0) }
        }
        
        func toDictionary() -> [String: Any] {
            return [
                "boyId": boyId,
                "boysName": boysName,
                "boysCellNumber": boysCellNumber,
                "dates": dates.map({$0.toDictionary()})
            ]
        }
    }
    
    func createArrayOfDatingHistoryFromArrayOfNasiDates() -> [BoyDatingHistory] {
    
        var allboyDatingHistoryArray =  [BoyDatingHistory]()
          for shidduch in selectedDatesArray {
            let boyId = shidduch.boyKey
            let boyName = shidduch.boyFullName
            let girlName = shidduch.girlFullName
            let boyCellNumber = shidduch.boyCellNumber
            var datingRelationship = DatingRelationship(boyId: boyId, boyName: boyName, girlName: girlName, boyCellNumber: boyCellNumber)
            
            if let index = allboyDatingHistoryArray.firstIndex(where:
            {$0.dates.contains(where: { $0.boyId == boyId }) })
            {
                // if the index is not nil then we append to existing
                allboyDatingHistoryArray[index].dates.append(datingRelationship)
            } else { // we neeed to create new dating history
               
                var newBoyDatingHistory = BoyDatingHistory(boyId: boyId, boysName: boyName, boysCellNumber: boyCellNumber, dates: [datingRelationship])
                allboyDatingHistoryArray.append(newBoyDatingHistory)
            }
        }
        return allboyDatingHistoryArray
    }
    
    func convertDatingHistoriesToFirebaseDict(arryOfDatingHistories: [BoyDatingHistory]) {
        var firebaseData:[[String: Any]] = []
        for history in arryOfDatingHistories {
            firebaseData.append(history.toDictionary())
        }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let boyDatingHistoryNodeRef = Database.database().reference().child("IOSBoysDatingHistory").child(uid)
        
        let newDatingHistoryRef = boyDatingHistoryNodeRef
        newDatingHistoryRef.setValue(firebaseData)
    
         print("firebaseData is\(firebaseData.debugDescription)")
     }
    func sendFirebaseDataToFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let boyDatingHistoryNodeRef = Database.database().reference().child("BoysDatingHistory").child(uid)
        
        let newDatingHistoryRef = boyDatingHistoryNodeRef.childByAutoId()
        //newDatingHistoryRef.setValue(firebaseDat)
        }
   
}

      
   





    
