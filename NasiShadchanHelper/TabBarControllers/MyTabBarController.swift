//
//  MyTabBarController.swift
//  NasiShadchanHelper
//
//  Created by username on 1/7/21.
//  Copyright © 2021 user. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
         self.delegate = self
        setupViewControllers()

    }
    
    //MARK:- UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("delegate method invoked")
        
       // if (viewController is UINavigationController) {
       //     let navcontrollers = viewController as? UINavigationController
        //    navcontrollers?.popViewController(animated: true)
       // }
        
     }
    
    
    func setupViewControllers() {
     
        let categoryController = CategoryViewController()
        //let homeNavController = UINavigationController(rootViewController: categoryController)
       // viewControllers = [homeNavController]
     
        //home
        //let homeController = HomeController(collectionViewLayout: UICollectionViewFlowLayout())
        let mainController = NasiSearchController()
        mainController.view.backgroundColor = .darkGray
        
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "checkedDay"), selectedImage: #imageLiteral(resourceName: "uncheckedDay"), rootViewController: mainController)
        
        //search
       // let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: UserSearchController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        tabBar.tintColor = .red
    
        
        viewControllers = [homeNavController]
        
        //modify tab bar item insets
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
     
        
    }
    
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
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
