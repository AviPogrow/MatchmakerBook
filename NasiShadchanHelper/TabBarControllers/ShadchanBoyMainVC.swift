//
//  ShadchanBoyMainVC.swift
//  NasiShadchanHelper
//
//  Created by test on 5/16/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import Firebase


class ShadchanBoyMainVC: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout, UISearchBarDelegate  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var  label: UILabel!
    
    // MARK: Properties
    var shadchanBoysArrayAll: [NasiBoy] = []
    var engaged: [NasiBoy] = []
    var filteredShadchanBoysList:[NasiBoy] = [NasiBoy]()
    
    let shadchanBoysListRef  = Database.database().reference().child("NasiBoysList")
    var selectedDatesArray: [NasiDate] = []
    var allboyDatingHistoryArray =  [DatingHistory]()
    

    let cellId = "cellId"
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter name"
        sb.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        sb.delegate = self
        sb.autocapitalizationType = .none
        sb.returnKeyType = .done
        return sb
        
    }()
    
    fileprivate let enterSearchTermLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter search term above..."
        label.textAlignment = .center
        label.textColor = .yellow
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Boy", style: .plain, target: self, action: #selector(handleAdd))
        

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        collectionView.register(ShadchanBoySearchResultCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = .systemBackground
        navigationController?.navigationBar.addSubview(searchBar)
        
        let navBar = navigationController?.navigationBar
        searchBar.isHidden = false
       
        let rect = CGRect.zero
        label = UILabel(frame: rect)
        label.backgroundColor = .systemPink
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Nasi"
        label.font = .boldSystemFont(ofSize: 24)
        label.layer.borderWidth = 0.0
        label.layer.borderColor = UIColor.systemPink.cgColor
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        navigationController?.navigationBar.addSubview(label)
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 90, paddingBottom: 0, paddingRight: 98, width: 0, height: 0)
        
        label.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: searchBar.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 44)
    }
    
    @objc func handleAdd() {
        let addEditController = AddEditBoyViewController()
        label.isHidden = true
        navigationController?.pushViewController(addEditController, animated: true)
        searchBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
        label.isHidden = false
        fetchAndCreateShadchanBoysArray()
        
        // get all users dates for all boys
        fetchAllDates()
    
    }
    
    
    // get all the users dates so that we can pull the dating history
    // for a boy when selected
    func fetchAllDates() {
        
        let datesListRef  = Database.database().reference().child("NasiDatesList")
        var selectedDatesArray: [NasiDate] = []
        var boyDatingHistories: [DatingHistory] = [DatingHistory]()
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
            selectedDatesArray = datesArray
            print("the dates array is \(selectedDatesArray)")
        self.createArrayOfDatingHistoryFromArrayOfNasiDates(datesArray: datesArray)
            
            self.collectionView.reloadData()
        })
    }
    
    
    
    func createArrayOfDatingHistoryFromArrayOfNasiDates(datesArray: [NasiDate]) -> [DatingHistory] {
    
        for shidduch in datesArray {
              
            let boyId = shidduch.boyKey
            let boyFirstName = shidduch.boyFirstName
            let boyLastName = shidduch.boyLastName
            let boyName = boyLastName + " " + boyFirstName
            let girlName = shidduch.girlFullName
            let boyCellNumber = shidduch.boyCellNumber
            let girlId = shidduch.girlKey
            let girlCellNumber = shidduch.girlCellNumber
            var datingRelationship = DatingRelationship(boyId: boyId, boyName: boyName, boyCellNumber: boyCellNumber, girlId: girlId, girlName: girlName, girlCellNumber: girlCellNumber)
            
            if let index = allboyDatingHistoryArray.firstIndex(where:
            {$0.dates.contains(where: { $0.boyId == boyId }) })
            {
                // if the index is not nil then we append to existing
                allboyDatingHistoryArray[index].dates.append(datingRelationship)
            } else { // we neeed to create new dating history
               
                var newBoyDatingHistory = DatingHistory(boyId: boyId, boysName: boyName, boysCellNumber: boyCellNumber, girlId: girlId, girlsName: girlName, girlsCellNumber: girlCellNumber, dates: [datingRelationship])
                
                allboyDatingHistoryArray.append(newBoyDatingHistory)
            }
        }
        
        print("state of \(allboyDatingHistoryArray.count)")
        return allboyDatingHistoryArray
    }
    
    
    
    func fetchAndCreateBoysArray() {
        
        self.view.showLoadingIndicator()
        shadchanBoysArrayAll.removeAll()
        guard let myId = UserInfo.curentUser?.id else {return}
        let currentUserBoysListRef = shadchanBoysListRef.child(myId)
        
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
            
            DispatchQueue.main.async(execute: {
                self.view.hideLoadingIndicator()
                self.filteredShadchanBoysList = boysArray
                self.collectionView.reloadData()
            })
        })
            
    }
    
    
    func fetchAndCreateShadchanBoysArray() {
        
        self.view.showLoadingIndicator()
        shadchanBoysArrayAll.removeAll()
        guard let myId = UserInfo.curentUser?.id else {return}
        let currentGirlsListRef = shadchanBoysListRef.child(myId)
        
        currentGirlsListRef.observe(.childAdded, with: { (snapshot) in
        print(snapshot)
        let shadchanBoy = NasiBoy(snapshot: snapshot)
            self.shadchanBoysArrayAll.append(shadchanBoy)
            
      self.shadchanBoysArrayAll = self.shadchanBoysArrayAll.filter { (boy) -> Bool in
                return shadchanBoy.status ==
                "available"
            }
        self.shadchanBoysArrayAll = self.shadchanBoysArrayAll.sorted(by: { ($0.boyLastName) < ($1.boyLastName)
                 })
          DispatchQueue.main.async(execute: {
                self.view.hideLoadingIndicator()
                self.filteredShadchanBoysList = self.shadchanBoysArrayAll
                self.collectionView.reloadData()
            })
        
    })
}

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.filteredShadchanBoysList = self.shadchanBoysArrayAll
            
        } else {
            self.filteredShadchanBoysList = self.shadchanBoysArrayAll.filter { (boy) -> Bool in
                
            return boy.boyFirstName.lowercased().contains(searchText.lowercased()) || boy.boyLastName.lowercased().contains(searchText.lowercased()) ||
            boy.city.lowercased().contains(searchText.lowercased())  ||
            boy.shadchanNotes.lowercased().contains(searchText.lowercased()) ||
          boy.sendResumeEmail.lowercased().contains(searchText.lowercased())
           }
        }
        self.collectionView?.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width /// 2 - 5
        return .init(width: width, height: 80)
        }
   
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return 0
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
         return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return insets
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredShadchanBoysList.count
     }
   
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ShadchanBoySearchResultCell
       
          cell.nameLabel.textAlignment = .center
          cell.nameLabel.adjustsFontSizeToFitWidth = true
          cell.nameLabel.numberOfLines = 0
          let boy = filteredShadchanBoysList[indexPath.item]
          
           
           let dobIntervalString = boy.dobIntervalString ?? ""
           let boyAge = boy.calculateAgeFrom(dobString: dobIntervalString)
           
          let boyAgeAsString = "\(boyAge)"
          
          var cellString = "N/A"
          if boy.boyCell == "" {
              cellString = "N/A"
          } else  {
              cellString = boy.boyCell
      }
          let stringForLabel = boy.boyLastName + " " + boy.boyFirstName + " " + "Age: " + " " + boyAgeAsString //+ " cell: " + cellString
          
          cell.nameLabel.backgroundColor = .cyan
          cell.nameLabel.text = stringForLabel
          
        return cell
       }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
         self.searchBar.resignFirstResponder()
         label.isHidden = true
         searchBar.isHidden = true
            
         let controller =  AddEditBoyViewController()

        var currentBoy: NasiBoy!
            
        currentBoy = filteredShadchanBoysList[indexPath.row]
        controller.selectedNasiBoy = currentBoy
        print("currentBoy: \(String(describing: currentBoy))")
        
        //get boys key and pass it to next vc
        let currentBoyKey: String!
        currentBoyKey = currentBoy.key
        controller.selectedNasiBoy.key = currentBoyKey
        var girlsNamesString: String = ""
        
        let filteredBoysDatingList = filterByBoyId(datingHistory: allboyDatingHistoryArray, boyId: currentBoyKey)
        
        if filteredBoysDatingList.first != nil {
            let datingRelationshipsArry = filteredBoysDatingList.first!.dates
            girlsNamesString = datingRelationshipsArry.map { $0.girlName } .joined(separator: "-")
            controller.datingHistory = girlsNamesString
            
        } else {
            controller.datingHistory = ""
        }
        
        navigationController?.pushViewController(controller, animated: true)
     }
    
    func filterByBoyId(datingHistory: [DatingHistory], boyId: String) -> [DatingHistory] {
        return datingHistory.filter { $0.boyId == boyId }
    }
    
    /*
    func filterDatingArrayUsingBoyKey(_ key: String) -> [BoyDatingHistory] {
        var filteredBoysDateList = [BoyDatingHistory]()
        for shidduch in self.allboyDatingHistoryArray {
            
            if shidduch.boyId == key {
                filteredBoysDateList.append(shidduch)
            }
        }
        
        return filteredBoysDateList
    }
     */
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShadchanBoysCategoriesVC" {
            label.isHidden = true
            searchBar.isHidden = true
            //logOutImageView.isHidden = true
            
            self.searchBar.resignFirstResponder()
            //let controller = segue.destination as! ShadchanBoysCategoriesVC
            //controller.shadchanGirlsArray  = self.shadchanGirlsArrayAll
        }
     }

    func calculateAgeFrom(dobString: String) -> Double {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        let backToDate = dateFormatter.date(from: dobString)
        print(backToDate!)
                    
        let calculatedAge = calculateAgeFrom(dob: backToDate!)
        
        return calculatedAge
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


class ShadchanBoySearchResultCell: UICollectionViewCell {
    /*
    var boy: NasiBoy! {
        didSet {
            
            /*
            // get the date of birth as string
            let dobString = boy.dobIntervalString
            
            // set up date formmatter to convert string to date
            let dateFormatter = DateFormatter()
            // Set Date Format
             dateFormatter.dateFormat = "YY/MM/dd"
            var ageString = "\(0)"
            
            // convert dobString to date object
            if  let date = dateFormatter.date(from: dobString) {
                // calculate the age and convert to string
                let age = try self.calculateAgeFrom(dob: date)
                ageString  = "\(age)"
            }
            */
            /*
            nameLabel.text = boy!.boyLastName + " " + boy!.boyFirstName + " - " + ageString
            nameLabel.textColor = .blue
            cityLabel.text = boy!.city + " - " + boy.boyHeight
            cityLabel.textColor = .blue
            ageLabel.text = boy!.boyHeight
            ageLabel.font = .systemFont(ofSize: 12)
            ageLabel.text = boy!.categories.joined(separator: "-")
            ageLabel.textColor = .blue
             */
        }
    }
    */
    let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let cityLabel: UILabel = {
        let label = UILabel()
        //label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 14)
        label.text = "city here"
        //label.backgroundColor = .lightText
        return label
    }()
    
    let ageLabel: UILabel = {
        let label = UILabel()
        //label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 14)
        label.text = "age here"
        //label.backgroundColor = .lightText
        return label
    }()
    
    
    
    let getButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Details", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = UIColor(white: 0.95, alpha: 1)
        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
        button.layer.cornerRadius = 16
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       
        addSubview(nameLabel)
        let insets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        nameLabel.fillSuperview(padding: insets)
      
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
    
   
