//
//  SelectBoyVC.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 12/15/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit

protocol CreateBoyControllerDelegate {
    func didAddBoy(boy: NasiBoy)
    
}

class SelectBoyVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    var delegate: CreateBoyControllerDelegate?
    
    fileprivate let cellId = "id12345"
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
   
    
    var boy: String!
    var filteredBoys = [String]()
    var allBoys = [String]()
    var selectedBoy: String!
    var arrayForDataModel = [String]()
    
    var boys = [NasiBoy]()
    var boysToSelectArray = [NasiBoy]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.title = "Select Boy"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        collectionView.backgroundColor = .white
        collectionView.register(BoySearchResultCell.self, forCellWithReuseIdentifier: cellId)
       setupSearchBar()
    }
    
    @objc func handleCancel() {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    // returns true or false if searchBar text is empty
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // if search controller is active and not empty
    // then we are filtering
    // but if its inactive or if its empty then
    // we arent filtering and need the full data set not filtered
    var isFiltering: Bool {
      return searchController.isActive && (!isSearchBarEmpty)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      
        
        var filteredResult =  self.boysToSelectArray.filter { (boy: NasiBoy) -> Bool in
                
            return boy.boyLastName.lowercased().contains(searchText.lowercased()) || boy.boyFirstName.lowercased().contains(searchText.lowercased())
        }
        
        if isFiltering {
            boysToSelectArray = filteredResult
        } else if isFiltering == false {
            boysToSelectArray = self.boys
        }
    
        self.collectionView.reloadData()
}
    
    
    fileprivate func setupSearchBar() {
        definesPresentationContext = true
        navigationItem.searchController = self.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter a boys first or last name"
        searchController.searchBar.delegate = self
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //enterSearchTermLabel.isHidden = appResults.count != 0
        return boysToSelectArray.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BoySearchResultCell
        
        cell.nameLabel.textAlignment = .center
        cell.nameLabel.adjustsFontSizeToFitWidth = true
        cell.nameLabel.numberOfLines = 0
        let boy = boysToSelectArray[indexPath.item]
        
        let dobIntervalString = boy.dobIntervalString ?? ""
        let boyAge = boy.calculateAgeFrom(dobString: dobIntervalString)
        
       let boyAgeAsString = "\(boyAge)"
       
        
        var cellString = "N/A"
        if boy.boyCell == "" {
            cellString = "N/A"
        } else  {
            cellString = boy.boyCell
        }
        let stringForLabel = boy.boyLastName + " " + boy.boyFirstName + " - " + "Age: " + boyAgeAsString //+ " - cell: " + cellString
        
        cell.nameLabel.backgroundColor = .cyan
        cell.nameLabel.text = stringForLabel
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBoy = boysToSelectArray[indexPath.row]
        delegate?.didAddBoy(boy: selectedBoy)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 88)
    }
    
    func calculateAgeFrom(dobString: String) -> Double {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        let backToDate = dateFormatter.date(from: dobString)
        
                    
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
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class BoySearchResultCell: UICollectionViewCell {

    let nameLabel: UILabel = {
        let label = UILabel()
        //label.textAlignment = .left
        //label.numberOfLines = 0
        label.text = "APP NAME"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .cyan.lighter()
        //nameLabel.backgroundColor = .lightGray
        addSubview(nameLabel)
        nameLabel.fillSuperview()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
