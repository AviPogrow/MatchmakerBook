//
//  BoyCategoriesVC.swift
//  NasiShadchanHelper
//
//  Created by test on 3/7/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class BoyCategoriesVC: UICollectionViewController {

    var arrayBoysListAll = [NasiBoy]()
    
    // section 0
    var arrOnetoThreeSingleBoys = [NasiBoy]()
    var arrThreeToFiveSingleBoys = [NasiBoy]()
  
    var arrFiveYearsSingleBoys = [NasiBoy]()
    var arrFiveToSevenSingleBoys = [NasiBoy]()
    var arrSevenPlusSingleBoys = [NasiBoy]()
    
    // section 1
    var arrNeedsProTrack = [NasiBoy]()
    var arrDoesNotNeedProTrack = [NasiBoy]()
    
    // section 2
    var arrNeedsKoveaIttim = [NasiBoy]()
    var arrDoesNotNeedKovea = [NasiBoy]()

    
    var sections = [[BoyGroup]]()
    
    required init?(coder: NSCoder) {
        super.init(collectionViewLayout: BoyCategoriesVC.createLayout())
        //fatalError("init(coder:) has not been implemented")
    }
    
    // init the layout object for the collection view
    init() {
        super.init(collectionViewLayout: BoyCategoriesVC.createLayout())
    }
    
    
    
    
    func fetchAndCreateBoysArray() {
      let boysListRef  = Database.database().reference().child("NasiBoysList")
        
        guard let myId = UserInfo.curentUser?.id else {return}
    let currentUserBoysListRef = boysListRef.child(myId)
    
    currentUserBoysListRef.observe(.value, with: { snapshot in
            var boysArray: [NasiBoy] = []
        for child in snapshot.children {
        let snapshot = child as? DataSnapshot
         let nasiBoy = NasiBoy(snapshot: snapshot!)
          boysArray.append(nasiBoy)
        }
        
        // take the full array and make it categories
        self.buildCategoriesArrays(boysArray: boysArray)
        self.sections = self.buildSections()
        
    })
}
    
    // pass in an array of boys and break them
    // into smaller sub arrays
    func buildCategoriesArrays(boysArray: [NasiBoy]) {
        let boyCategories = ["FTL - 1-3",
                             "FTL - 3-5",
                             "FTL - 5",
                             "FTL - 5-7",
                             "FTL - 7+",
                             "PTL - School",
                             "PTL - Working",
                             "FTW/College-Yeshiva Style",
                             "FTW/College-Not Yeshiva Style"]
        
        // create array of FTL 1-3
        self.arrOnetoThreeSingleBoys =  boysArray.filter { nasiBoy in
            nasiBoy.categories.contains("FTL - 1-3")
        }
        
       // create array of FTL 3-5
        self.arrThreeToFiveSingleBoys =  boysArray.filter { nasiBoy in
            nasiBoy.categories.contains("FTL - 3-5")
        }
        
       
        // create array of FTL 5
        self.arrFiveYearsSingleBoys =  boysArray.filter { nasiBoy in
            nasiBoy.categories.contains("FTL - 5")
        }
        // create array of FTL 5-7
        self.arrFiveToSevenSingleBoys =  boysArray.filter { nasiBoy in
            nasiBoy.categories.contains("FTL - 5-7")
        }
        // create array of FTL 7+
        self.arrSevenPlusSingleBoys =  boysArray.filter { nasiBoy in
            nasiBoy.categories.contains("FTL - 7+")
        }
        
        // create array of PTL
        self.arrNeedsProTrack =  boysArray.filter { nasiBoy in
            nasiBoy.categories.contains("FTL - 7+")
        }
        // create array of PTL
        self.arrDoesNotNeedProTrack =  boysArray.filter { nasiBoy in
            nasiBoy.categories.contains("FTL - 7+")
        }
        
        self.arrNeedsKoveaIttim = boysArray.filter { nasiBoy in
            nasiBoy.categories.contains("FTW/College-Yeshiva Style")
        }
        
        self.arrDoesNotNeedKovea = boysArray.filter { nasiBoy in
            nasiBoy.categories.contains("FTW/College-Not Yeshiva Style")
        }
        
    }
        
    func buildSections() -> [[BoyGroup]] {
        var  sections = [[BoyGroup]]()
        
        let fTLGroupOneToThree = BoyGroup(imageString: "threeboys", titleString: "FTL 1-3 Years", arrayOfNasiBoys: arrOnetoThreeSingleBoys)
        let fTLGroupThreeToFive = BoyGroup(imageString: "threeboys", titleString: "FTL 3-5 Years", arrayOfNasiBoys: arrThreeToFiveSingleBoys)
        let fTLFive = BoyGroup(imageString: "threeboys", titleString: "FTL 5 Years", arrayOfNasiBoys: arrFiveYearsSingleBoys)
        
        let fTLGroupFiveToSeven = BoyGroup(imageString: "AviLearning", titleString: "FTL 5-7 Years", arrayOfNasiBoys: arrFiveToSevenSingleBoys)
        
        let fTLGroupSeven = BoyGroup(imageString: "AviLearning", titleString: "FTL 7+", arrayOfNasiBoys: arrSevenPlusSingleBoys)
        
        let pTLNeedsPro = BoyGroup(imageString: "AviAndMoishe", titleString: "PTL - School", arrayOfNasiBoys: arrNeedsProTrack)
        
        let PTLDoesNotNeedPro = BoyGroup(imageString: "mosheyehuda", titleString: "PTL - Working", arrayOfNasiBoys: arrDoesNotNeedProTrack)
        
        let fTWNeedsKovea = BoyGroup(imageString: "AviLearning", titleString: "FTW - Yeshiva Style", arrayOfNasiBoys: arrNeedsKoveaIttim)
        
        let fTWDoesNotNeedKovea = BoyGroup(imageString: "AviYoung", titleString: "FTW - Not Yeshiva Style", arrayOfNasiBoys: arrDoesNotNeedKovea)
        
        // each section contains an array for girl groups
        let section0 = [fTLGroupOneToThree,fTLGroupThreeToFive,fTLFive,fTLGroupFiveToSeven,fTLGroupSeven]
        
        let section1 = [pTLNeedsPro,PTLDoesNotNeedPro]
        let section2 = [fTWNeedsKovea,fTWDoesNotNeedKovea]
       
        sections = [section0,section1,section2]
        
      return sections
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        fetchAndCreateBoysArray()
        sections = buildSections()
        
        collectionView.backgroundColor = .white
        navigationItem.title = "Categories"
        
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: categoryCell)
        
        collectionView.register(CategoryHeader.self, forSupplementaryViewOfKind: CategoryViewController.categoryHeaderId, withReuseIdentifier: headerId)
    }
    
    private let categoryCell = "categoryCell"
    let headerId = "headerId"
    static let categoryHeaderId = "categoryHeaderId"
    
    static func createLayout() -> UICollectionViewCompositionalLayout {
        
        
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
    
    var section: NSCollectionLayoutSection!
            
    if sectionNumber == 0 {
        
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/1), heightDimension: .fractionalHeight(1)))
        
        item.contentInsets.leading = 6
//                item.contentInsets.bottom = 16
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(8/12), heightDimension: .fractionalHeight(1/3)), subitems: [item])
        var section0 = NSCollectionLayoutSection(group: group)
        
        section0.orthogonalScrollingBehavior = .paging
        
        section0.boundarySupplementaryItems = [
            .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70)), elementKind: self.categoryHeaderId, alignment: .topLeading)
        ]
        
         section = section0
    }
     else  {
        
        let item = NSCollectionLayoutItem.init(layoutSize: .init(widthDimension: .fractionalWidth(1/1), heightDimension: .fractionalHeight(1/1)))
        item.contentInsets.leading = 6
         
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(16/30), heightDimension: .fractionalHeight(1/3)), subitems: [item])
        
        // take the group and build a layout section
         var section2 = NSCollectionLayoutSection(group: group)
        
        section2.orthogonalScrollingBehavior = .continuous
        section2.boundarySupplementaryItems = [
            .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70)), elementKind: self.categoryHeaderId, alignment: .topLeading)
        ]
        //section2.contentInsets.leading = 16
        section = section2
    }
            return section
    }
  }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // get the right group to pass to the next vc
        let selectedGroup = sections[indexPath.section][indexPath.item]
        
        selectedGroup.arrayOfNasiBoys.debugDescription
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "BoySubCategoriesVC") as! BoySubCategoriesVC
        
        controller.selectedBoysGroup = selectedGroup
      
        self.navigationController!.pushViewController(controller, animated: true)
        }
    

    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! CategoryHeader
        
        let categories = ["Full Time Learning","Part Time Learning","Full Time College/Working"]
        
        let currentCategory = categories[indexPath.section]
        header.headerLabel.text = currentCategory
        
        return header
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let categories = ["Full Time Learning","Full Time Working/College","Part Time Learning"]
        return sections.count
    }
    
let FTLOptions =
    ["Boys-1-3-Years","Boys-3-5-Years","Boys-5-Years","Boys-5-7-Years","Boys-7+-Years"]
    let FTWOptions = ["YeshivaStyleBoys","NotYeshivaStyleBoys"]
    let PTOptions = ["School","Working"]
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCell, for: indexPath) as! CategoryCell
        cell2.categoryLabel.isHidden = true
        let currentSection = sections[indexPath.section]
        let currentGroup = currentSection[indexPath.item]
        let imageTitle = currentGroup.imageString
        var categoryName: String = ""
        if indexPath.section == 0 {
             categoryName = FTLOptions[indexPath.item]
        } else if indexPath.section == 1 {
             categoryName = PTOptions[indexPath.item]
        } else {
             categoryName = FTWOptions[indexPath.item]
        }
       
        cell2.category = categoryName
        cell2.currentImageID = categoryName
        
        if indexPath.section == 0 {
        cell2.categoryLabel.font = .systemFont(ofSize: 18)
        } else {
            cell2.categoryLabel.font = .systemFont(ofSize: 18)
        }
        
        cell2.layer.shadowOpacity = 0.6
        cell2.layer.shadowRadius = 5
        return cell2
    }
    
 
    }

 
