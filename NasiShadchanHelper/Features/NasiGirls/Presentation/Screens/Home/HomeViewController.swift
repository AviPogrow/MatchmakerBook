//
//  HomeViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 12/5/22.
//  Copyright © 2022 user. All rights reserved.
//

import UIKit
import Firebase


class HomeViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout, UISearchBarDelegate  {
    
  
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: NasiGirlsViewModel!
    
    var onNasiGirlSelected: ((NasiGirl) -> Void)?

    fileprivate let enterSearchTermLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter search term above..."
        label.textAlignment = .center
        label.textColor = .yellow
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    var logOutImageView: UIImageView!
    let cellId = "cellId"
    var  label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        navigationItem.title = "All Nasi Girls"
        
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: cellId)
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
        
        
        let rect2 = CGRect.zero
        logOutImageView = UIImageView(frame: rect2)
        logOutImageView.backgroundColor = .tertiarySystemBackground
        logOutImageView.image = UIImage(imageLiteralResourceName: "imgLogout" )
        
        logOutImageView.contentMode = .scaleAspectFit
        logOutImageView.layer.borderWidth = 0.0
        logOutImageView.layer.borderColor = UIColor.systemPink.cgColor
        logOutImageView.layer.cornerRadius = 8
        logOutImageView.clipsToBounds = true
        navigationController?.navigationBar.addSubview(logOutImageView)
        //logOutImageView.backgroundColor = .yellow
        logOutImageView.isUserInteractionEnabled = true
        logOutImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogOut)))
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 90, paddingBottom: 0, paddingRight: 64, width: 0, height: 0)
        
        label.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: searchBar.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 44)
        
        logOutImageView.anchor(top: navBar?.topAnchor, left: searchBar.rightAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 44)
        
        fetchAndCreateNasiGirlsArray()
        homeScreenLaunchToFB()
    }
    
    
    func homeScreenLaunchToFB() {
        let now = "\(Date())"
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let homeScreenLaunch = UserLaunch(timesStamp: now, shadchanID: uid)
        
        let dict = homeScreenLaunch.toAnyObject()
        
        let homeScreenLaunchFBNode = Database.database().reference().child("HomeScreenLaunch").child(uid)
        
        let currentHomeScreenLaunchFBNode = homeScreenLaunchFBNode.childByAutoId()
        currentHomeScreenLaunchFBNode.setValue(dict)
        
    }
    
    @objc func handleLogOut() {
        
        let alertControler = UIAlertController.init(title:"Logout", message: Constant.ValidationMessages.msgLogout, preferredStyle:.alert)
        
        alertControler.addAction(UIAlertAction.init(title:"Yes", style:.default, handler: { (action) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            // removes it from user defaults
            UserInfo.resetCurrentUser()
            
            // make the authVC the rootVC
          //  AppDelegate.instance().makingRootFlow(Constant.AppRootFlow.kAuthVc)
        }))
        
        alertControler.addAction(UIAlertAction.init(title:"No", style:.destructive, handler: { (action) in
        }))
        self.present(alertControler,animated:true, completion:nil)
    }
        
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
        label.isHidden = false
        logOutImageView.isHidden = false
    }
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter name, city, seminary"
        sb.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        sb.delegate = self
        sb.autocapitalizationType = .none
        sb.returnKeyType = .done
        return sb
        
    }()
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchActive = false
        self.searchBar.endEditing(true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterGirls(searchText: searchText)
        collectionView.reloadData()
    }
  
    
    func fetchAndCreateNasiGirlsArray() {
        view.showLoadingIndicator()

        Task {
            do {
                try await viewModel.loadGirls()

                await MainActor.run {
                    self.view.hideLoadingIndicator()
                    self.collectionView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.view.hideLoadingIndicator()
                    print("Failed to fetch Nasi girls:", error)
                }
            }
        }
    }
    
    
    
    /*
    func fetchAndCreateNasiGirlsArray() {
        view.showLoadingIndicator()
        allNasiGirlsList.removeAll()

        let ref = Database.database().reference().child("NasiGirlsList")

        ref.observeSingleEvent(of: .value) { snapshot in
            var girls: [NasiGirl] = []
            girls.reserveCapacity(Int(snapshot.childrenCount))

            for child in snapshot.children {
                guard let snap = child as? DataSnapshot else { continue }
                let nasiGirl = NasiGirl(snapshot: snap)
                girls.append(nasiGirl)
            }

            // Filter once
            girls = girls.filter { $0.category != Constant.CategoryTypeName.CategoryEngaged1 }

            // Sort once
            girls.sort { $0.lastNameOfGirl < $1.lastNameOfGirl }

            DispatchQueue.main.async {
                self.view.hideLoadingIndicator()
                self.allNasiGirlsList = girls
                self.filteredNasiGirlsList = girls
                self.collectionView.reloadData()
            }
        }
    }
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width / 2 - 5
        return .init(width: width, height: 240)
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
       // enterSearchTermLabel.isHidden = appResults.count != 0
         return viewModel.filteredGirls.count
      }
    
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchResultCell
        
         
           cell.girl = viewModel.filteredGirls[indexPath.item]
           
           return cell
        }
    
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.searchBar.resignFirstResponder()
        label.isHidden = true
        searchBar.isHidden = true
        logOutImageView.isHidden = true
        
        let identifier = "ShadchanListDetailViewController"
       
        let currentGirl = viewModel.filteredGirls[indexPath.item]
          onNasiGirlSelected?(currentGirl)
        
        }
    
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CategoryVC" {
            label.isHidden = true
            searchBar.isHidden = true
            logOutImageView.isHidden = true
            
            self.searchBar.resignFirstResponder()
            let controller = segue.destination as! CategoryViewController
            controller.arrayGirlsList = viewModel.allGirls        }
    }
   
}

extension UIView {
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }

}
