//
//  ShadchanGirlMainVC.swift
//  NasiShadchanHelper
//
//  Created by test on 5/17/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import ContactsUI

class ShadchanGirlMainVC: UIViewController,
    UICollectionViewDataSource,UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout, UISearchBarDelegate, CNContactPickerDelegate  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var  label: UILabel!
  
    // MARK: Properties
    var shadchanGirlsArrayAll: [ShadchanGirl] = []
    var engaged: [ShadchanGirl] = []
    var filteredShadchanGirlsList:[ShadchanGirl] = [ShadchanGirl]()
    let shadchanGirlsListRef  = Database.database().reference().child("PrivateGirlsList")
    
    var allGirlDatingHistoryArray =  [DatingHistory]()
    

    let cellId = "cellID"
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter first or last name"
        sb.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        sb.delegate = self
        sb.autocapitalizationType = .none
        sb.returnKeyType = .done
        return sb
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Girl", style: .plain, target: self, action: #selector(handleAdd))
        
        navigationItem.title = "Girl Categories"
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        collectionView.register(ShadchanGirlSearchResultCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.addSubview(searchBar)
        let navBar = navigationController?.navigationBar
        searchBar.isHidden = false
       
        
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openNextScreen), for: .touchUpInside)
        //button.font = .boldSystemFont(ofSize: 24)
        button.layer.borderWidth = 0.0
        button.layer.borderColor = UIColor.systemPink.cgColor
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        navigationController?.navigationBar.addSubview(button)
        

        let rect = CGRect.zero
        label = UILabel(frame: rect)
        label.backgroundColor = .systemPink
        label.textColor = .green
        label.textAlignment = .center
        label.text = "Test"
        label.font = .boldSystemFont(ofSize: 24)
        label.layer.borderWidth = 0.0
        label.layer.borderColor = UIColor.systemPink.cgColor
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        //navigationController?.navigationBar.addSubview(label)
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 90, paddingBottom: 0, paddingRight: 98, width: 0, height: 0)
        
        button.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: searchBar.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 44)
    }
    
    @objc private func openNextScreen() {
        
            let vc = GirlsFilterSearchVC()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }

       
    @objc func handleAdd() {

        //showAddGirlOptions()
        
        let addEditController = AddEditGirlViewController()
        label.isHidden = true
        navigationController?.pushViewController(addEditController, animated: true)
        searchBar.isHidden = true
    }
    func handleAddManually() {
        let addEditController = AddEditGirlViewController()
        label.isHidden = true
        navigationController?.pushViewController(addEditController, animated: true)
        searchBar.isHidden = true
        
    }
     func handleScanResumeWithDocScanner() {
        let docScannerVC = ScannerViewController()
        self.navigationController?.pushViewController(docScannerVC, animated: true)
       }
    
    func importFromContacts() {
        let store = CNContactStore()
        switch
        CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            self.presentContactPicker()
            
            
        case .notDetermined:
            //request access
            store.requestAccess(for: .contacts) { (granted, error) in
                if granted {
                    self.presentContactPicker()
                } else {
                    //  self.showAccessDeniedAlert()
                }
            }
        default :
            self.showAccessDeniedAlert()
            
        }
    }
        
    func showAccessDeniedAlert() {
        let alert = UIAlertController(title: "Contacts Access Denied" , message: "Please enable contacts access in settings in Settings to import contacts.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        present(alert, animated: true)
    }
        
    func presentContactPicker() {
        /*
        let contactPickerVC = CNContactPickerViewController()
        
        contactPickerVC.delegate = self
        contactPickerVC.displayedPropertyKeys =
        [CNContactGivenNameKey,
         CNContactFamilyNameKey,
         CNContactPhoneNumbersKey,
        CNContactEmailAddressesKey]
        present(contactPickerVC, animated: true)
         */
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
      importContact(contact)
    }
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        dismiss(animated: true)
    }
    func importContact(_ contact: CNContact){
        let name = "\(contact.givenName) \(contact.familyName)"
        let phoneNumbers = contact.phoneNumbers.map({$0.value as CNPhoneNumber})
        let emails = contact.emailAddresses.map({$0.value as String})
        
        print("imported contact: \(name), \(phoneNumbers), \(emails)")
        
    }
    
    @objc func showAddGirlOptions() {
        let alert = UIAlertController(title: "Add Girl", message: "Choose how you'd like to add a girl", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Add Manually", style: .default, handler: { (_) in
            self.handleAddManually()
        }))
        
        alert.addAction(UIAlertAction(title: "Import From Contacts", style: .default, handler: { (_) in
            self.importFromContacts()
        }))
        alert.addAction(UIAlertAction(title: "Scan Resume", style: .default, handler: { (_) in
            self.handleScanResumeWithDocScanner()
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert,animated: true)
    }
    
    func fetchAndCreateShadchanGirlsArray() {
        
        self.view.showLoadingIndicator()
        shadchanGirlsArrayAll.removeAll()
        guard let myId = UserInfo.curentUser?.id else {return}
        let currentGirlsListRef = shadchanGirlsListRef.child(myId)
        
        currentGirlsListRef.observe(.childAdded, with: { (snapshot) in
            
        let shadchanGirl = ShadchanGirl(snapshot: snapshot)
        self.shadchanGirlsArrayAll.append(shadchanGirl)
        
        self.shadchanGirlsArrayAll = self.shadchanGirlsArrayAll.sorted(by: { ($0.girlLastName) < ($1.girlLastName)
                 })
          DispatchQueue.main.async(execute: {
                self.view.hideLoadingIndicator()
                self.filteredShadchanGirlsList = self.shadchanGirlsArrayAll
                self.collectionView.reloadData()
            })
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
        label.isHidden = false
         fetchAndCreateShadchanGirlsArray()
        fetchAllDates()
    }
    
    // get all the users dates
    // convert the array of user dates into an array of Dating Histories
    func fetchAllDates() {
        let datesListRef  = Database.database().reference().child("NasiDatesList")
        
        var selectedDatesArray: [NasiDate] = []
       
        var girlDatingHistories: [DatingHistory] = [DatingHistory]()
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
        
            // convert the array of nasi dates to an array of dating //histories
            self.createArrayOfDatingHistoryFromArrayOfNasiDates(datesArray: datesArray)
            
            self.collectionView.reloadData()
        })
    }
    
    
    // after we fetch all the Nasi Dates
    // takes the array of Nasi Dates
    // and converts it to an array of All Dating histories
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
            
            if let index = allGirlDatingHistoryArray.firstIndex(where:
            {$0.dates.contains(where: { $0.girlId == girlId }) })
            {
                // if the index is not nil then we append to existing
                allGirlDatingHistoryArray[index].dates.append(datingRelationship)
            } else { // we neeed to create new dating history
               
                var newGirlDatingHistory = DatingHistory(boyId: boyId, boysName: boyName, boysCellNumber: boyCellNumber, girlId: girlId, girlsName: girlName, girlsCellNumber: girlCellNumber, dates: [datingRelationship])
                
                allGirlDatingHistoryArray.append(newGirlDatingHistory)
            }
        }
        print("state of \(allGirlDatingHistoryArray.count)")
        return allGirlDatingHistoryArray
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        self.searchBar.endEditing(true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.filteredShadchanGirlsList = self.shadchanGirlsArrayAll
            
        } else {
            self.filteredShadchanGirlsList = self.shadchanGirlsArrayAll.filter { (girl) -> Bool in
                return
            
                girl.girlFirstName.lowercased().contains(searchText.lowercased()) || girl.girlLastName.lowercased().contains(searchText.lowercased()) ||   girl.city.lowercased().contains(searchText.lowercased()) ||  girl.shadchanNotesNew.lowercased().contains(searchText.lowercased()) ||  girl.sendResumeEmail.lowercased().contains(searchText.lowercased())
                
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
       
        return  filteredShadchanGirlsList.count
     }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ShadchanGirlSearchResultCell
    
        cell.nameLabel.textAlignment = .center
        cell.nameLabel.adjustsFontSizeToFitWidth = true
        cell.nameLabel.numberOfLines = 0
        let girl = filteredShadchanGirlsList[indexPath.item]
     
        let dobIntervalString = girl.dobIntervalString ?? ""
        let girlAge = girl.calculateAgeFrom(dobString: dobIntervalString)
        
       let girlAgeAsString = "\(girlAge)"
       
        let path = indexPath.row
        
        var cellString = "N/A"
        if girl.girlCell == "" {
            cellString = "N/A"
        } else  {
            cellString = girl.girlCell
        }
        let stringForLabel = "\(path)" + ": " + girl.girlLastName + " " + girl.girlFirstName + " - " + "Age: " + girlAgeAsString  //+ " - cell: " + cellString
        
        cell.nameLabel.textColor = .systemPink.lighter()
        cell.nameLabel.text = stringForLabel
        
        return cell
     }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
         self.searchBar.resignFirstResponder()
         label.isHidden = true
         searchBar.isHidden = true
            
         let controller =  AddEditGirlViewController()
    

        var currentGirl: ShadchanGirl!
            
        currentGirl = filteredShadchanGirlsList[indexPath.row]
        
        // clean up the life option strings to be backward compatible
        currentGirl.categories = LifePlanNormalizer.normalizeArray(currentGirl.categories)

        controller.selectedShadchanGirl = currentGirl
        
         let currentGirlKey: String!
        currentGirlKey = currentGirl.key
        controller.selectedShadchanGirl.key = currentGirlKey
        var girlsNamesString: String = ""
         
         let filteredGirlsDatingList = filterByGirlId(datingHistory: allGirlDatingHistoryArray, girlId: currentGirlKey)
         
         if filteredGirlsDatingList.first != nil {
             let datingRelationshipsArry = filteredGirlsDatingList.first!.dates
             
             girlsNamesString = datingRelationshipsArry.map { $0.boyName } .joined(separator: "-")
             controller.datingHistory = girlsNamesString
             
         } else {
             controller.datingHistory = ""
         }
         
        navigationController?.pushViewController(controller, animated: true)
     }
    
     func filterByGirlId(datingHistory: [DatingHistory], girlId: String) -> [DatingHistory] {
         return datingHistory.filter { $0.girlId == girlId }
     }
     
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShadchanGirlsCategoriesVC" {
            label.isHidden = true
            searchBar.isHidden = true
            //logOutImageView.isHidden = true
            
            self.searchBar.resignFirstResponder()
            let controller = segue.destination as! ShadchanGirlsCategoriesVC
            controller.shadchanGirlsArray  = self.shadchanGirlsArrayAll
        }
     }

}

import UIKit


class ShadchanGirlSearchResultCell: UICollectionViewCell {
   
    let nameLabel: UILabel = {
        let label = UILabel()
       
        label.text = "APP NAME"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(nameLabel)
        let insets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        nameLabel.fillSuperview(padding: insets)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




  

