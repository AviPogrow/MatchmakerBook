//
//  CategoriesViewController.swift
//  NasiShadchanHelper
//
//  Created by user on 4/24/20.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit
import Firebase
import ObjectMapper

class CategoriesViewController: UIViewController {
    
    var ref: DatabaseReference!
    var arrayOfNasiGirls = [NasiGirl]()
    var selectedNasiBoy: NasiBoy!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedNasiBoy != nil {
            navigationItem.title = selectedNasiBoy.boyFirstName + " " + selectedNasiBoy.boyLastName
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
    
      fetchAndCreateNasiGirlsArray()
    }
    
    func fetchAndCreateNasiGirlsArray() {
      self.view.showLoadingIndicator()
      
    //  get the node
      let allNasiGirlsRef = Database.database().reference().child("NasiGirlsList")
        
     allNasiGirlsRef.observe(.value, with: { snapshot in
        
         var nasiGirlsArray: [NasiGirl] = []
    
         for child in snapshot.children {
              
            let snapshot = child as? DataSnapshot
            let nasiGirl = NasiGirl(snapshot: snapshot!)
            
            nasiGirlsArray.append(nasiGirl)
        }
        
        self.arrayOfNasiGirls = nasiGirlsArray
        self.view.hideLoadingIndicator()
         self.setBadgeCount()
      })
    }
    // MARK: -Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    
    func setBadgeCount() {
        if let tabItems = self.tabBarController?.tabBar.items {
            if arrayOfNasiGirls.count > 0 {
                let tabItem = tabItems[0]
                tabItem.badgeValue = "\(arrayOfNasiGirls.count)" // set Badge count you need
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        
        if segue.identifier == "ShowFullTimeYeshiva" {
            
            /*
            Analytics.logEvent("categories_action", parameters: [
                "item_name": "Full Time Yeshiva",
            ])
            */
            
            let controller = segue.destination as! FullTimeYeshivaViewController
            controller.arrGirlsList = arrayOfNasiGirls
            controller.selectedNasiBoy = selectedNasiBoy
            
        } else if segue.identifier == "ShowFullTimeCollege/Working" {
            
            /*
            Analytics.logEvent("categories_action", parameters: [
                "item_name": "Full Time College/Working",
            ])
             */
            
            let controller = segue.destination as! FullTimeCollegeWorkingViewController
                controller.arrGirlsList = arrayOfNasiGirls
            controller.selectedNasiBoy = selectedNasiBoy
            
            } else if segue.identifier  == "ShowYeshivaAndCollege/Working" {
            
            /*
            Analytics.logEvent("categories_action", parameters: [
                "item_name": "Yeshiva And College/Working",
            ])
 */
            
            let controller = segue.destination as! YeshivaAndCollegeWorkingViewController
            controller.arrGirlsList = arrayOfNasiGirls
                controller.selectedNasiBoy = selectedNasiBoy
        }
    }
}

// MARK:- IBActions
extension CategoriesViewController {
    @IBAction func btnlogoutAction(_ sender: Any) {
        
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
            //AppDelegate.instance().makingRootFlow(Constant.AppRootFlow.kAuthVc)
        }))
        
        alertControler.addAction(UIAlertAction.init(title:"No", style:.destructive, handler: { (action) in
        }))
        self.present(alertControler,animated:true, completion:nil)
    }
}


