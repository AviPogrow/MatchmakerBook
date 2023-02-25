//
//  SubCategoryVC.swift
//  NasiShadchanHelper
//
//  Created by test on 2/10/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SubCategoryVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

  
    var selectedGroup: GirlGroup!
    
    

    
    required init?(coder aDecoder: NSCoder) {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
   // func commonInit() {
        
         //   super.
        
   // }
    

    override func viewDidLoad() {
    super.viewDidLoad()
        navigationItem.title = selectedGroup.titleString
        print("the state is \(selectedGroup.debugDescription)")
        collectionView.register(GirlCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
      
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
       
        return selectedGroup.arrayOfNasiGirls.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GirlCollectionViewCell
        
    
        let currentGirl = selectedGroup.arrayOfNasiGirls[indexPath.item]
        cell.girl = currentGirl
        
        
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width / 1 - 5
        
            return .init(width: width, height: 200)
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedGirl = selectedGroup.arrayOfNasiGirls[indexPath.item]
       let id =  "ShadchanListDetailViewController"
        let detailVC = storyboard!.instantiateViewController(withIdentifier: id) as! ShadchanListDetailViewController
        detailVC.selectedNasiGirl = selectedGirl
        navigationController?.pushViewController(detailVC, animated: true)
    }

}
