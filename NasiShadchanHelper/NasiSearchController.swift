//
//  NasiSearchController.swift
//  NasiShadchanHelper
//
//  Created by test on 11/25/22.
//  Copyright © 2022 user. All rights reserved.
//
import UIKit
import Firebase
//import SDWebImage

class NasiSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    fileprivate let cellId = "id1234"
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    var allNasiGirlsList: [NasiGirl] = [NasiGirl]()
    var filteredNasiGirlsList:[NasiGirl] = [NasiGirl]()
    
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
        
        
      
        collectionView.backgroundColor = .white
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.addSubview(enterSearchTermLabel)
        enterSearchTermLabel.fillSuperview(padding: .init(top: 100, left: 50, bottom: 0, right: 50))
        
        setupSearchBar()
        fetchAndCreateNasiGirlsArray()
    }
    
    
    fileprivate func setupSearchBar() {
        definesPresentationContext = true
        navigationItem.searchController = self.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.filteredNasiGirlsList = self.allNasiGirlsList
        } else {
            self.filteredNasiGirlsList = self.allNasiGirlsList.filter { (girl) -> Bool in
                return girl.lastNameOfGirl.lowercased().contains(searchText.lowercased()) || girl.firstNameOfGirl.lowercased().contains(searchText.lowercased()) || girl.cityOfResidence.lowercased().contains(searchText.lowercased())
            }
        }
        
        self.collectionView?.reloadData()
        
    }
    
    
    
func fetchAndCreateNasiGirlsArray() {
    
  self.view.showLoadingIndicator()
    
  allNasiGirlsList.removeAll()
    
  let allNasiGirlsRef = Database.database().reference().child("NasiGirlsList")
    
    guard let myId = UserInfo.curentUser?.id else {return}
    
    allNasiGirlsRef.observe(.childAdded, with: { (snapshot) in
    
    let nasiGirl = NasiGirl(snapshot: snapshot)
    self.allNasiGirlsList.append(nasiGirl)
   
    self.allNasiGirlsList = self.allNasiGirlsList.sorted(by: { ($0.lastNameOfGirl) < ($1.lastNameOfGirl)
        
    })
        
    // if girl is in engaged category then take her out
    self.allNasiGirlsList = self.allNasiGirlsList.filter { (singleGirl) -> Bool in
        return singleGirl.category != Constant.CategoryTypeName.CategoryEngaged1
    }
        
        // order by last name of girl
        self.allNasiGirlsList = self.allNasiGirlsList.sorted(by: { ($0.lastNameOfGirl ) < ($1.lastNameOfGirl ) })
        

    DispatchQueue.main.async(execute: {
    self.view.hideLoadingIndicator()
        
        self.filteredNasiGirlsList = self.allNasiGirlsList
        
    self.collectionView.reloadData()
    })
  })
}
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.bounds.width
        return .init(width: width, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return insets
    }
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       // enterSearchTermLabel.isHidden = appResults.count != 0
        return filteredNasiGirlsList.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchResultCell
       cell.girl = filteredNasiGirlsList[indexPath.item]
        
        //cell.backgroundColor = .green
        return cell
    }
}

