//
//  SelectGirlVC.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 12/17/23.
//  Copyright © 2023 user. All rights reserved.
//


import UIKit

protocol CreateGirlControllerDelegate {
    func didAddGirl(girl: Girl)
    
}

class SelectGirlVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    var delegate: CreateGirlControllerDelegate?
    
    fileprivate let cellId = "id123456"
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    var girls = [Girl]()
    var girlsToSelectArray = [Girl]()
    var girl: Girl!
    var filteredGirls = [Girl]()
    var allGirls = [Girl]()
    var selectedGirl: Girl!
    var arrayForDataModel = [Girl]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Select Girl"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        collectionView.backgroundColor = .white
        collectionView.register(GirlSearchResultCell.self, forCellWithReuseIdentifier: cellId)
       setupSearchBar()
    }
    @objc func handleCancel() {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    // returns true or false if searchBar text is empty
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
      return searchController.isActive && (!isSearchBarEmpty)
    }
   
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      
        
        var filteredResult =  self.girlsToSelectArray.filter { (girl: Girl) -> Bool in
                
            return girl.lastName.lowercased().contains(searchText.lowercased()) || girl.firstName.lowercased().contains(searchText.lowercased())
        }
        
        if isFiltering {
            girlsToSelectArray = filteredResult
        } else if isFiltering == false {
            girlsToSelectArray = self.girls
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
        return girlsToSelectArray.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GirlSearchResultCell
        cell.nameLabel.textAlignment = .center
        cell.nameLabel.adjustsFontSizeToFitWidth = true
        cell.nameLabel.numberOfLines = 0
        let girl = girlsToSelectArray[indexPath.item]
        

        var cellString = "N/A"
        //if girl.girlCell == "" {
      //      cellString = "N/A"
      //  } else  {
      //      cellString = girl.girlCell
     //   }
        let stringForLabel = girl.lastName + " " + girl.firstName + " - " + "Age: " + girl.ageString //+ " - cell: " + cellString
        
        
        cell.nameLabel.backgroundColor = .systemPink.lighter()
        cell.nameLabel.text = stringForLabel
        
        return cell
    
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedGirl = girlsToSelectArray[indexPath.row]
        delegate?.didAddGirl(girl: selectedGirl)
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 88)
    }
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class GirlSearchResultCell: UICollectionViewCell {
    /*
    var girl: ShadchanGirl! {
        didSet {
            nameLabel.text = girl.girlLastName + " " + girl.girlFirstName + " " + girl.key
            nameLabel.textAlignment = .center
            nameLabel.numberOfLines = 3
        }
    }
     */
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "APP NAME"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(nameLabel)
        nameLabel.fillSuperview()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

