//
//  ShadchanGirlsCategoriesVC.swift
//  NasiShadchanHelper
//
//  Created by test on 5/20/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ShadchanGirlsCategoriesVC: UICollectionViewController {
    let headerId = "headerId"
    static let categoryHeaderId = "categoryHeaderId"

    var shadchanGirlsArray: [ShadchanGirl]!
    //= [ShadchanGirl]()
    
    var sections = [[ShadchanGirlGroup]]()
    // section 0
    var arrOnetoThreeSingleGirls = [ShadchanGirl]()
    var arrThreeToFiveSingleGirls = [ShadchanGirl]()
  
    var arrFiveYearsSingleGirls = [ShadchanGirl]()
    var arrFiveToSevenSingleGirls = [ShadchanGirl]()
    var arrSevenPlusSingleGirls = [ShadchanGirl]()
    
    // section 1
    var arrNeedsProTrack = [ShadchanGirl]()
    var arrDoesNotNeedProTrack = [ShadchanGirl]()
    
    // section 2
    var arrNeedsKoveaIttim = [ShadchanGirl]()
    var arrDoesNotNeedKovea = [ShadchanGirl]()
    
    required init?(coder: NSCoder) {
        super.init(collectionViewLayout: BoyCategoriesVC.createLayout())
        
    }
    init() {
        super.init(collectionViewLayout: ShadchanGirlsCategoriesVC.createLayout())
    }
    
    static func createLayout() -> UICollectionViewCompositionalLayout {
        
    return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
    var section: NSCollectionLayoutSection!
        if sectionNumber == 0 {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/1), heightDimension: .fractionalHeight(1/3)))
        item.contentInsets.leading = 6
//      item.contentInsets.bottom = 16
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(8/12), heightDimension: .fractionalHeight(1/9)), subitems: [item])
        
        var section0 = NSCollectionLayoutSection(group: group)
        section0.orthogonalScrollingBehavior = .paging
        section0.boundarySupplementaryItems = [
            .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70)), elementKind: self.categoryHeaderId, alignment: .topLeading)
        ]
        section = section0
        }
        else  {
        
        let item = NSCollectionLayoutItem.init(layoutSize: .init(widthDimension: .fractionalWidth(1/1), heightDimension: .fractionalHeight(1/8)))
        item.contentInsets.leading = 6
         
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(16/30), heightDimension: .fractionalHeight(1/8)), subitems: [item])
        var section2 = NSCollectionLayoutSection(group: group)
        section2.orthogonalScrollingBehavior = .continuous
        section2.boundarySupplementaryItems = [
            .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70)), elementKind: self.categoryHeaderId, alignment: .topLeading)
        ]
        section = section2
        }
            return section
         }
       }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: categoryCell)
        collectionView.register(CategoryHeader.self, forSupplementaryViewOfKind: ShadchanGirlsCategoriesVC.categoryHeaderId, withReuseIdentifier: headerId)
        buildCategoriesArrays()
        buildSections()
        }
    
    
    func buildCategoriesArrays() {
        
        self.arrOnetoThreeSingleGirls = self.shadchanGirlsArray.filter { shadchanGirl in
            shadchanGirl.categories.contains("FTL - 1-3")
        }
        
        print(self.arrOnetoThreeSingleGirls.first?.girlLastName)
        
        self.arrThreeToFiveSingleGirls = self.shadchanGirlsArray.filter { shadchanGirl in
            shadchanGirl.categories.contains("FTL - 3-5")
        }
        
        
        self.arrFiveYearsSingleGirls = self.shadchanGirlsArray.filter { shadchanGirl in
            shadchanGirl.categories.contains("FTL - 5")
        }
        
        self.arrFiveToSevenSingleGirls = self.shadchanGirlsArray.filter { shadchanGirl in
            shadchanGirl.categories.contains("FTL - 5-7")
        }
        
        self.arrSevenPlusSingleGirls = self.shadchanGirlsArray.filter { shadchanGirl in
            shadchanGirl.categories.contains("FTL - 7+")
        }
        
        //self.shadchanGirlsArray.sort(by: { (girl1, girl2) -> Bool in
         //return girl1.girlLastName < girl2.girlLastName
        //})
        
       
        
       // self.shadchanGirlsArrayFTL.sort(by: { (girl1, girl2) -> Bool in
       //  return girl1.dateLastUpdate > girl2.dateLastUpdate
       // })
        /*
         girlCategories = ["FTL - 1-3",
                                   "FTL - 3-5",
                                   "FTL - 5",
                                   "FTL - 5-7",
                                   "FTL - 7+",
                                   "PTL - School",
                                   "PTL - Working",
                                   "FTW/College-Yeshiva Style",
                                   "FTW/College-Not Yeshiva Style"]
         
         */
        self.arrNeedsProTrack = self.shadchanGirlsArray.filter { shadchanGirl in
            shadchanGirl.categories.contains("PTL - School")
        }
        
        self.arrDoesNotNeedProTrack = self.shadchanGirlsArray.filter { shadchanGirl in
            shadchanGirl.categories.contains("PTL - Working")
        }
        
      //  self.shadchanGirlsArrayPTL.sort(by: { (girl1, girl2) -> Bool in
       //  return girl1.dateLastUpdate > girl2.dateLastUpdate
      //  })
        
        self.arrNeedsKoveaIttim =   self.shadchanGirlsArray.filter { shadchanGirl in
            shadchanGirl.categories.contains("FTW/College-Yeshiva Style")
            
        }
        
        self.arrDoesNotNeedKovea =    self.shadchanGirlsArray.filter { shadchanGirl in
            shadchanGirl.categories.contains("FTW/College-Not Yeshiva Style")
        }
        
       // self.shadchanGirlsArrayCollegeWorking.sort(by: { (girl1, girl2) -> Bool in
       //  return girl1.dateLastUpdate > girl2.dateLastUpdate
       // })
    }
    
    func buildSections() -> [[ShadchanGirlGroup]] {
        
        //var  sections = [[ShadchanGirlGroup]]()
        
       
        let fTLGroupOneToThree = ShadchanGirlGroup(imageString: "nasiGirl1-3", titleString: "FTL 1-3 Years", arrayOfShadchanGirls: arrOnetoThreeSingleGirls)
        
        let fTLGroupThreeToFive = ShadchanGirlGroup(imageString: "Tepper", titleString: "FTL 3-5 Years", arrayOfShadchanGirls: arrThreeToFiveSingleGirls)
        
        let fTLFive = ShadchanGirlGroup(imageString: "Kramer", titleString: "FTL 5 Years", arrayOfShadchanGirls: arrFiveYearsSingleGirls)
        let fTLGroupFiveToSeven = ShadchanGirlGroup(imageString: "Spivak", titleString: "FTL 5-7 Years", arrayOfShadchanGirls: arrFiveToSevenSingleGirls)
        let fTLGroupSeven = ShadchanGirlGroup(imageString: "Cohen", titleString: "FTL 7+", arrayOfShadchanGirls: arrSevenPlusSingleGirls)
        
        let pTLNeedsPro = ShadchanGirlGroup(imageString: "Shochet", titleString: "PTL - School", arrayOfShadchanGirls: arrNeedsProTrack)
        
        let PTLDoesNotNeedPro = ShadchanGirlGroup(imageString: "rosen", titleString: "PTL - Working", arrayOfShadchanGirls: arrDoesNotNeedProTrack)
        
        let fTWNeedsKovea = ShadchanGirlGroup(imageString: "kush", titleString: "FTW - Yeshiva Style", arrayOfShadchanGirls: arrNeedsKoveaIttim)
        
        let fTWDoesNotNeedKovea = ShadchanGirlGroup(imageString: "Brissman", titleString: "FTW - Not Yeshiva Style", arrayOfShadchanGirls: arrDoesNotNeedKovea)
        
        // each section contains an array for girl groups
        let section0 = [fTLGroupOneToThree,fTLGroupThreeToFive,fTLFive,fTLGroupFiveToSeven,fTLGroupSeven]
        let section1 = [pTLNeedsPro,PTLDoesNotNeedPro]
        let section2 = [fTWNeedsKovea,fTWDoesNotNeedKovea]
        
        // make an array of sections
        self.sections = [section0,section1,section2]
        
        return sections
    }

   
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let categories = ["Full Time Learning","Full Time Working/College","Part Time Learning"]
        return sections.count
        
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  sections[section].count
    }

    private let categoryCell = "CategoryCell"
    let FTLOptions = ["Girl-1-3 Years","Girl-3-5 Years","Girl-5 Years","Girl-5-7 Years","Girl-7+ Years"]
    let FTWOptions = ["YeshivaStyleGirls","NotYeshivaStyleGirls"]
    let PTOptions = [
        "School","Working"]
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
       
        cell2.category =  categoryName
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! CategoryHeader
        
        let categories = ["Full Time Learning","Part Time Learning","Full Time Working/College"]
        
        let currentCategory = categories[indexPath.section]
        header.headerLabel.text = currentCategory
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // get the right group to pass to the next vc
        let selectedGroup = sections[indexPath.section][indexPath.item]
        
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "ShadchanGirlSubcategoryVC") as! ShadchanGirlSubcategoryVC
        
        controller.selectedGroup = selectedGroup
        navigationController?.pushViewController(controller,animated: true)
        
    }

}
