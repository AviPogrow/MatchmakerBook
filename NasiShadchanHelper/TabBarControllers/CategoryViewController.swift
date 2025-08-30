//
//  CategoryViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 1/1/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit
import StoreKit

private let reuseIdentifier = "Cell"

class CategoryViewController: UICollectionViewController {

    
    var arrayGirlsList = [NasiGirl]()
    
    // section 0
    var arrOnetoThreeSingleGirls = [NasiGirl]()
    var arrThreeToFiveSingleGirls = [NasiGirl]()
  
    var arrFiveYearsSingleGirls = [NasiGirl]()
    var arrFiveToSevenSingleGirls = [NasiGirl]()
    var arrSevenPlusSingleGirls = [NasiGirl]()
    
    // section 1
    var arrNeedsProTrack = [NasiGirl]()
    var arrDoesNotNeedProTrack = [NasiGirl]()
    
    // section 2
    var arrNeedsKoveaIttim = [NasiGirl]()
    var arrDoesNotNeedKovea = [NasiGirl]()

    var sections = [[GirlGroup]]()
    
    func buildSections() -> [[GirlGroup]] {
        
        var  sections = [[GirlGroup]]()
        
        let fTLGroupOneToThree = GirlGroup(imageString: "Glatt", titleString: "FTL 1-3 Years", arrayOfNasiGirls: arrOnetoThreeSingleGirls)
        
        let fTLGroupThreeToFive = GirlGroup(imageString: "Tepper", titleString: "FTL 3-5 Years", arrayOfNasiGirls: arrThreeToFiveSingleGirls)
        let fTLFive = GirlGroup(imageString: "Kramer", titleString: "FTL 5 Years", arrayOfNasiGirls: arrFiveYearsSingleGirls)
        let fTLGroupFiveToSeven = GirlGroup(imageString: "Spivak", titleString: "FTL 5-7 Years", arrayOfNasiGirls: arrFiveToSevenSingleGirls)
        let fTLGroupSeven = GirlGroup(imageString: "Cohen", titleString: "FTL 7+", arrayOfNasiGirls: arrSevenPlusSingleGirls)
        
        let pTLNeedsPro = GirlGroup(imageString: "Shochet", titleString: "PTL - Needs Pro Track", arrayOfNasiGirls: arrNeedsProTrack)
        
        let PTLDoesNotNeedPro = GirlGroup(imageString: "rosen", titleString: "PTL - Doesn't Need Pro Track", arrayOfNasiGirls: arrDoesNotNeedProTrack)
        
        let fTWNeedsKovea = GirlGroup(imageString: "kush", titleString: "FTW - Yeshiva Style", arrayOfNasiGirls: arrNeedsKoveaIttim)
        
        let fTWDoesNotNeedKovea = GirlGroup(imageString: "Brissman", titleString: "FTW - Not Yeshiva Style", arrayOfNasiGirls: arrDoesNotNeedKovea)
        
        // each section contains an array for girl groups
        let section0 = [fTLGroupOneToThree,fTLGroupThreeToFive,fTLFive,fTLGroupFiveToSeven,fTLGroupSeven]
        let section1 = [pTLNeedsPro,PTLDoesNotNeedPro]
        let section2 = [fTWNeedsKovea,fTWDoesNotNeedKovea]
        
        // make an array of sections
        sections = [section0,section1,section2]
        
        return sections
    }
    
    
    required init?(coder: NSCoder) {
        super.init(collectionViewLayout: CategoryViewController.createLayout())
        //fatalError("init(coder:) has not been implemented")
    }
    
    // init the layout object for the collection view
    init() {
        super.init(collectionViewLayout: CategoryViewController.createLayout())
    }
    
    
    
    
    static func createLayout() -> UICollectionViewCompositionalLayout {
        
        
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
    
    var section: NSCollectionLayoutSection!
            
    if sectionNumber == 0 {
        
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/1), heightDimension: .fractionalHeight(1)))
        
        item.contentInsets.leading = 6
//                item.contentInsets.bottom = 16
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(5/12), heightDimension: .fractionalHeight(1/3)), subitems: [item])
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
        let controller = storyboard!.instantiateViewController(withIdentifier: "SubCategoryVC") as! SubCategoryVC
        
        controller.selectedGroup = selectedGroup
        navigationController?.pushViewController(controller,animated: true)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let categories = ["Full Time Learning","Full Time Working/College","Part Time Learning"]
        return sections.count
    }
    
    let FTLOptions = ["1-3 Years","3-5 Years","5 Years","5-7 Years","7+ Years"]
    let FTWOptions = ["Yeshiva Style","Not Yeshiva Style"]
    let PTOptions = ["Needs Pro Track","Doesn't Need Pro Track"]
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCell, for: indexPath) as! CategoryCell
        
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
        cell2.currentImageID = imageTitle
        
        if indexPath.section == 0 {
        cell2.categoryLabel.font = .systemFont(ofSize: 18)
        } else {
            cell2.categoryLabel.font = .systemFont(ofSize: 18)
        }
        //cell2.layer.cornerRadius = 8
       // cell2.clipsToBounds = true
        //cell2.layer.borderWidth = 0.33
        //cell2.layer.borderColor = UIColor.red.cgColor
        cell2.layer.shadowOpacity = 0.6
        cell2.layer.shadowRadius = 5
        
        
        //let gradientLayer = CAGradientLayer()
        //gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        //gradientLayer.locations = [0.5, 1.1]
        //gradientLayer.frame = cell2.bounds
        //cell2.layer.addSublayer(gradientLayer)
        return cell2
    }
    
    private let categoryCell = "categoryCell"
    let headerId = "headerId"
    static let categoryHeaderId = "categoryHeaderId"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        SKStoreReviewController.requestReview()
        
        //static let kPredicateString1 = "FTL"
       // static let kPredicateString2 = "FTL+PTL+FTC"
        //static let kPredicateString3 = "FTL+PTL"
        //static let kCategoryString0 = "FTC"
        //static let kCategoryString1 = "PTL+FTC"
        //static let kCategoryString3 = "PTL"
        
        //static let CategoryEngaged1 = "Engaged1"
        
        self.arrayGirlsList = self.arrayGirlsList.filter { (girlList) -> Bool in
            return
           
            girlList.category == Constant.CategoryTypeName.kPredicateString1  || girlList.category == Constant.CategoryTypeName.kPredicateString2 || girlList.category == Constant.CategoryTypeName.kPredicateString3 ||
            girlList.category == Constant.CategoryTypeName.kCategoryString0 ||
            girlList.category == Constant.CategoryTypeName.kCategoryString1 ||
            girlList.category == Constant.CategoryTypeName.kCategoryString3
            
        }
        
        /*Segment Section Filter*/
        arrOnetoThreeSingleGirls = arrayGirlsList.filter { singleGirl in
            singleGirl.yearsOfLearning == "1-3" || singleGirl.yearsOfLearning == "1-3:3-5" ||
                singleGirl.yearsOfLearning == "1-3:3-5:5" ||
            singleGirl.yearsOfLearning == "1-3:3-5:5:5-7" ||
            singleGirl.yearsOfLearning == " 1-3:3-5:5:5-7:7+"
        }
    
        arrThreeToFiveSingleGirls = arrayGirlsList.filter { singleGirl in
            singleGirl.yearsOfLearning == "3-5" ||
           singleGirl.yearsOfLearning == "1-3:3-5" ||
                singleGirl.yearsOfLearning == "1-3:3-5:5" ||
                singleGirl.yearsOfLearning == "3-5:5" ||
            singleGirl.yearsOfLearning == "1-3:3-5:5:5-7" ||
            singleGirl.yearsOfLearning == "1-3:3-5:5:5-7:7+" ||
                singleGirl.yearsOfLearning == "3-5:5:5-7" ||
            singleGirl.yearsOfLearning == "3-5:5:5-7:7+"
        }
    
        arrFiveYearsSingleGirls = self.arrayGirlsList.filter { (singleGirl) -> Bool in
            return singleGirl.yearsOfLearning == "5" ||
                singleGirl.yearsOfLearning == "5:5-7" ||
                singleGirl.yearsOfLearning == "1-3:3-5:5:5-7:7+" ||
                singleGirl.yearsOfLearning == "3-5:5:5-7:7+" ||
                singleGirl.yearsOfLearning == "1-3:3-5:5:5-7" ||
                singleGirl.yearsOfLearning == "1-3:3-5:5" ||
                singleGirl.yearsOfLearning == "3-5:5" ||
                singleGirl.yearsOfLearning == "3-5:5:5-7" ||
                singleGirl.yearsOfLearning == "5:5-7:7+"
        }
        
        arrFiveToSevenSingleGirls = self.arrayGirlsList.filter { singleGirl in
            singleGirl.yearsOfLearning == "5-7" ||
            singleGirl.yearsOfLearning == "3-5:5:5-7:7" ||
            singleGirl.yearsOfLearning == "1-3:3-5:5:5-7" ||
            singleGirl.yearsOfLearning == "3-5:5:5-7" ||
            singleGirl.yearsOfLearning == "3-5:5:5-7:7+" ||
            singleGirl.yearsOfLearning == "5:5-7" ||
            singleGirl.yearsOfLearning == "5-7:7" ||
            singleGirl.yearsOfLearning == "5-7:7+"
        }
        
        arrSevenPlusSingleGirls = self.arrayGirlsList.filter { singleGirl in
            singleGirl.yearsOfLearning == "7+" ||
            singleGirl.yearsOfLearning == "5:5-7:7+" ||
            singleGirl.yearsOfLearning == "5-7:7+" ||
            singleGirl.yearsOfLearning == "3:3-5:5:5-7:7+" ||
            singleGirl.yearsOfLearning == "3-5:5:5-7:7+"
        }
        //arrOnetoThreeSingleGirls
        arrOnetoThreeSingleGirls = self.arrOnetoThreeSingleGirls.sorted(by: { Double($0.age ) < Double($1.age ) })
        
        arrThreeToFiveSingleGirls = self.arrThreeToFiveSingleGirls.sorted(by: { Double($0.age ) < Double($1.age ) })
        
        arrFiveYearsSingleGirls = self.arrFiveYearsSingleGirls.sorted(by: { Double($0.age ) < Double($1.age ) })
        
        arrFiveToSevenSingleGirls = self.arrFiveToSevenSingleGirls.sorted(by: { Double($0.age ) < Double($1.age ) })
        
        
        arrSevenPlusSingleGirls = self.arrSevenPlusSingleGirls.sorted(by: { Double($0.age ) < Double($1.age ) })
        
    
        self.arrDoesNotNeedProTrack = self.arrayGirlsList.filter { (singleGirl) -> Bool in
            return singleGirl.professionalTrack == "does not need professional track" || singleGirl.professionalTrack == "Does not need professional track"
        }
        
        self.arrNeedsProTrack = self.arrayGirlsList.filter { (singleGirl) -> Bool in
            return singleGirl.professionalTrack == "Needs professional track"
        }
        
        arrDoesNotNeedProTrack = self.arrDoesNotNeedProTrack.sorted(by: { Double($0.age ) < Double($1.age ) })
        
        arrNeedsProTrack = self.arrNeedsProTrack.sorted(by: { Double($0.age ) < Double($1.age ) })
        
        
        // make one array for needs and kovea and one for
        // does not need
        arrNeedsKoveaIttim = self.arrayGirlsList.filter { (singleGirl) -> Bool in
            return singleGirl.koveahIttim == "Need koveah ittim"
        }
    
        arrDoesNotNeedKovea = self.arrayGirlsList.filter { (singleGirl) -> Bool in
            
            return singleGirl.koveahIttim == "does not need koveah ittim"
        }
        
        arrNeedsKoveaIttim = self.arrNeedsKoveaIttim.sorted(by: { Double($0.age ) < Double($1.age ) })
        
        arrDoesNotNeedKovea = self.arrDoesNotNeedKovea.sorted(by: { Double($0.age ) < Double($1.age ) })
        sections = buildSections()
        
        collectionView.backgroundColor = .white
        navigationItem.title = "Categories"
        
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: categoryCell)
        
        collectionView.register(CategoryHeader.self, forSupplementaryViewOfKind: CategoryViewController.categoryHeaderId, withReuseIdentifier: headerId)
        }
    }

   
