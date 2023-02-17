//
//  ShadchanVCViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 2/17/23.
//  Copyright © 2023 user. All rights reserved.
//

import UIKit

class ShadchanVCViewController: UIViewController {
    
    
    
    @IBOutlet weak var myGirlsButton: UIButton!
    
    @IBOutlet weak var myMatches: UIButton!
    
    let accessList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkForAccess()

     
   
            
        
    }
    
    func fetchAccessListArray() -> [String] {
   
     
      let accessList = [String]()
      return accessList
    }
    func checkForAccess() {
       
      
        //get the list
let accessUserArray =    ["VdpgEVKTc5eJHyKtA6jjzXIodwT2",
    "FbM5JVwEsQhjALAhY8TKZZTW2lp2","sJNVs2tgVCav6pwz6FaKKSOhhZm2","IYY5JzXwHvOwd5vQd9Hg8txz4ml1","6N8PrDYD5bdbbLQSoWhPkROSwd62"]
    
        let currentUserID = (UserInfo.curentUser?.id)!
        print("my id is \(currentUserID)")
        
        
        
        let hasAccess = accessUserArray.contains(currentUserID)
        //myMatches.isEnabled = hasAccess
        //myGirlsButton.isEnabled = hasAccess
        // in array
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
