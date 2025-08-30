//
//  MatchIdeaDetailVC.swift
//  NasiShadchanHelper
//
//  Created by test on 3/2/23.
//  Copyright © 2023 user. All rights reserved.
//


import UIKit
import Eureka
import Firebase
import ImageRow
import ViewRow

class MatchIdeaDetailVC: FormViewController {

    var selectedMatchIdea: MatchIdea!
    let ideaListRef = Database.database().reference().child("shadchanNasiMatchIdea")
    var moveButton: UIButton!
    var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save Idea", style: .plain, target: self, action: #selector(saveToIdeas))
        
        navigationItem.title = "Idea Details"

   
        form +++

            Section("Name of Boy and Girl")

            <<< LabelRow () {
            
                $0.title = selectedMatchIdea.boyFirstName  + " " + selectedMatchIdea.boyLastName + " & " + selectedMatchIdea.girlFirstName + " " + selectedMatchIdea.girlLastName
                }
        
        form
            +++
                Section("Level of Connection Between Shadchan and Girl") //section 2
            <<< ActionSheetRow<String>() {
                
                   $0.title = "Select an Option"
                // $0.selectorTitle = "Choose from Match Idea"
                $0.options = ["Never Met","Spoke once","Multiple Contacts"]
            }
        
        form
            +++
                Section("Help Redding this idea?") //section 2
            <<< ActionSheetRow<String>() {
                
                   $0.title = "Select an Option"
                // $0.selectorTitle = "Choose from Match Idea"
                $0.options = ["YES","NO","Maybe"]
            }
        form    +++ Section("Idea Notes")

            <<< TextAreaRow() {
                $0.value = " " //selectedNasiBoy.shadchanNotes ?? ""
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 66)
            }

    form +++
        Section("Move to Redds")
        <<< ViewRow<UIView>()
            .cellSetup { [self] (cell, row) in
            cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 64))
        
            let rect = CGRect(x: 0, y: 0, width: 0, height:0)
            moveButton = UIButton(frame: rect)
            moveButton.tag = 1001
            moveButton.setTitle(title: "Move to Redds List")
            moveButton.titleLabel?.font = .boldSystemFont(ofSize: 26)
                moveButton.backgroundColor = .systemPink
            cell.view!.addSubview(moveButton)
            moveButton.fillSuperview()
            moveButton.addTarget(self, action: #selector(self.handleMove), for: .touchUpInside)
            }
        form +++
        Section("Send Info:")
            <<< ViewRow<UIView>()
                .cellSetup { [self] (cell, row) in
                cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 88))
            
                let rect = CGRect(x: 0, y: 0, width: 0, height:0)
                sendButton = UIButton(frame: rect)
                sendButton.tag = 1001
                sendButton.setTitle(title: "Send Girls Information")
                sendButton.titleLabel?.font = .boldSystemFont(ofSize: 26)
                sendButton.backgroundColor = .systemGreen
                cell.view!.addSubview(sendButton)
                sendButton.fillSuperview()
                sendButton.addTarget(self, action: #selector(self.handleSend), for: .touchUpInside)
                }
        
    }
    @objc func handleSend() {
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let astoryboard = UIStoryboard(name: "Main", bundle: nil)
       
    let sendController = astoryboard.instantiateViewController(withIdentifier: "ResumeViewController") as! ResumeViewController
        sendController.selectedMatchIdea = self.selectedMatchIdea
    self.navigationController?.pushViewController(sendController, animated: true)
    }
    @objc func saveToIdeas() {
        
    }
    
    @objc func handleMove() {
        
            //change the current stage to third date
            // so it filters out of the current list
            selectedMatchIdea.currentStage = "redd"
            let dict = selectedMatchIdea.toAnyObject()
            let ref = selectedMatchIdea.ref
            ref?.updateChildValues(dict as! [AnyHashable : Any])
            self.navigationController?.popToRootViewController(animated: true)
            }
    
    

}
