//
//  BoySubCategoriesVC.swift
//  NasiShadchanHelper
//
//  Created by test on 5/5/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class BoySubCategoriesVC: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    var selectedBoysGroup: BoyGroup!

    required init?(coder aDecoder: NSCoder) {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = selectedBoysGroup.titleString
        print("the state is \(selectedBoysGroup.debugDescription)")
        collectionView.register(BoyCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
    
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return selectedBoysGroup.arrayOfNasiBoys.count
    }


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BoyCollectionViewCell
    
       let currentBoy = selectedBoysGroup.arrayOfNasiBoys[indexPath.item]
        cell.boy = currentBoy
        //cell.backgroundColor = .yellow
    
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width / 1 - 5
        
            return .init(width: width, height: 100)
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
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddEditBoyViewController") as! AddEditBoyViewController

        var currentNasiBoy: NasiBoy!
      
       currentNasiBoy =   selectedBoysGroup.arrayOfNasiBoys[indexPath.row]
       controller.selectedNasiBoy = currentNasiBoy
        navigationController?.pushViewController(controller, animated: true)
       
    }
    

}
