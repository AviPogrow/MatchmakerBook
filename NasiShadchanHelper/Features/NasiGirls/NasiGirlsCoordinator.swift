//
//  GirlsCoordinator.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 5/26/26.
//  Copyright © 2026 user. All rights reserved.
//

import UIKit

final class NasiGirlsCoordinator {
    
    private let navigationController: UINavigationController
    private let container: AppContainer
    
    init(
          navigationController: UINavigationController,
          container: AppContainer
      ) {
          self.navigationController = navigationController
          self.container = container
      }
    func start() {
       let storyboard = UIStoryboard(name: "Main", bundle: nil)

          let listVC = storyboard.instantiateViewController(
              withIdentifier: "HomeViewController"
          ) as! HomeViewController
        navigationController.setViewControllers([listVC], animated: false)
        }
}
