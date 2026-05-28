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
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    init(
          navigationController: UINavigationController,
          container: AppContainer
      ) {
          self.navigationController = navigationController
          self.container = container
      }
    
    func start() {
      
        let listVC = storyboard.instantiateViewController(
              withIdentifier: "HomeViewController"
          ) as! HomeViewController
        
        navigationController.setViewControllers([listVC], animated: false)
        
        let repository = FirebaseNasiGirlsRepository()
        let viewModel = NasiGirlsViewModel(repository: repository)
        
        listVC.viewModel = viewModel
       // the listVC has this closure as an instance property
       //
        listVC.onNasiGirlSelected = { [weak self] girl in
            self?.showDetail(for: girl)
        }
    }
    
    private func showDetail(for girl: NasiGirl) {
        let identifier = "ShadchanListDetailViewController"

        let detailVC = storyboard.instantiateViewController(
            withIdentifier: identifier
        ) as! ShadchanListDetailViewController

        detailVC.selectedNasiGirl = girl
        
        detailVC.onSendResumeTapped = { [weak self] girl in
            self?.showSendResume(for: girl)
        }
        detailVC.onContactsTapped = { [weak self] girl in
            self?.showContacts(for: girl)
        }
        
        detailVC.onViewResumeTapped = { [weak self] girl in
            self?.showViewResume(for: girl)
        }

        navigationController.pushViewController(
            detailVC,
            animated: true
        )
    }
    private func showContacts(for girl: NasiGirl) {
        let vc = storyboard.instantiateViewController(
            withIdentifier: "ContactsViewController"
        ) as! ContactsViewController

        vc.selectedNasiGirl = girl
        navigationController.pushViewController(vc, animated: true)
    }
    private func showViewResume(for girl: NasiGirl) {
        let vc = storyboard.instantiateViewController(
            withIdentifier: "ViewResumeVCViewController"
        ) as! ViewResumeVCViewController

        vc.selectedNasiGirl = girl
        navigationController.pushViewController(vc, animated: true)
    }
   
    
    private func showSendResume(for girl: NasiGirl) {
        let vc = storyboard.instantiateViewController(
            withIdentifier: "ResumeViewController"
        ) as! ResumeViewController

        vc.selectedNasiGirl = girl

        navigationController.pushViewController(vc, animated: true)
    }
}
