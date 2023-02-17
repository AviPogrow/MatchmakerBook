//
//  ContactsViewController.swift
//  NasiShadchanHelper
//
//  Created by test on 2/5/22.
//  Copyright © 2022 user. All rights reserved.
//

import UIKit
import MessageUI

class ContactsViewController: UITableViewController {

    var selectedNasiGirl: NasiGirl!
    
    
    @IBOutlet weak var toDiscussTextView: UITextView!
    @IBOutlet weak var toReddTextView: UITextView!
    @IBOutlet weak var girlTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateToDiscussTextField()
        populateToReddTextField()
        populateGirlTextField()
    }
    
    func addDashesToCellString(originalString: String) -> String{
        var  finalString = ""
        var startingString = originalString
        let dash: Character = "-"
        
        print("the original string is\(originalString)")
        if originalString != "N/A" {
        
        let firstDashIndex =  originalString.index(originalString.startIndex, offsetBy: 3)
        let secondDashIndex = originalString.index(originalString.startIndex, offsetBy: 7)
        
        startingString.insert(dash, at: firstDashIndex)
        startingString.insert(dash, at: secondDashIndex)
        //let fourthIndex = cafeCombining.index(originalString.startIndex,
       //                                       offsetBy: 3)
        //let fourthChar = originalString[fourthIndex]
        
        finalString = startingString
        } else {
        finalString = "N/A"
        }

        return finalString
    }
    
    func populateToDiscussTextField() {
        
        let toDiscussNameString = selectedNasiGirl.firstNameOfAContactWhoKnowsGirl + " " + selectedNasiGirl.lastNameOfAContactWhoKnowsGirl
        var toDiscussTelString = selectedNasiGirl.cellNumberOfContactWhoKNowsGirl
        
        let telString = addDashesToCellString(originalString: toDiscussTelString)
        
        print(telString)
        
        
        
        
        let toDiscussEmailstring = selectedNasiGirl.emailOfContactWhoKnowsGirl
        let relationToGirlString = selectedNasiGirl.relationshipOfThisContactToGirl
        
        let attributedText = NSMutableAttributedString(string: toDiscussNameString, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22)])
        
        attributedText.append(NSAttributedString(string: "\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: telString, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]))
        attributedText.append(NSAttributedString(string: "\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]))
        
        attributedText.append(NSAttributedString(string: toDiscussEmailstring, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]))
        attributedText.append(NSAttributedString(string: "\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]))
        
        attributedText.append(NSAttributedString(string:relationToGirlString, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]))
        
        toDiscussTextView.attributedText = attributedText
    }
    
    func populateToReddTextField() {
        
        let toReddNameString = selectedNasiGirl.firstNameOfPersonToContactToReddShidduch + " " + selectedNasiGirl.lastNameOfPersonToContactToReddShidduch
        let toReddTelString = selectedNasiGirl.cellNumberOfContactToReddShidduch
        
        let telString = addDashesToCellString(originalString: toReddTelString)
        let toReddEmailstring = selectedNasiGirl.emailOfContactToReddShidduch
        let relationToGirlString = selectedNasiGirl.relationshipOfReddShidduchContactToGirl
        
    
        let attributedText = NSMutableAttributedString(string: toReddNameString, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22)])
        
        attributedText.append(NSAttributedString(string: "\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: telString, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]))
        attributedText.append(NSAttributedString(string: "\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]))
        
        attributedText.append(NSAttributedString(string: toReddEmailstring, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]))
        attributedText.append(NSAttributedString(string: "\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]))
        
        attributedText.append(NSAttributedString(string:relationToGirlString, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]))
        
        toReddTextView.attributedText = attributedText
    }
    
    func populateGirlTextField() {
        
        let girlNameString = selectedNasiGirl.nameSheIsCalledOrKnownBy + " " + selectedNasiGirl.lastNameOfGirl
        let girlTelString = selectedNasiGirl.girlsCellNumber
        
        let telString = addDashesToCellString(originalString: girlTelString)
        
        let girlEmailstring = selectedNasiGirl.girlsEmailAddress
        
        
    
        let attributedText = NSMutableAttributedString(string: girlNameString, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22)])
        
        attributedText.append(NSAttributedString(string: "\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        
        attributedText.append(NSAttributedString(string: telString, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]))
        attributedText.append(NSAttributedString(string: "\n", attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]))
        
        attributedText.append(NSAttributedString(string: girlEmailstring, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]))
        girlTextView.attributedText = attributedText
        }
        
    @IBAction func callContactToDisccuss(_ sender: Any) {
        Utility.makeACall(selectedNasiGirl.cellNumberOfContactWhoKNowsGirl)
    }
    
    
    @IBAction func textContactToDiscuss(_ sender: Any) {
        if !MFMessageComposeViewController.canSendText() {
            print("SMS services are not available")
        }
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        let toDiscussTelString =
        selectedNasiGirl.cellNumberOfContactWhoKNowsGirl
         
        // Configure the fields of the interface.
        composeVC.recipients = [toDiscussTelString]
        //composeVC.body = "HelloXXXXXXXXXX"
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    @IBAction func emailContactToDiscuss(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            
    let subjectString = "Regarding" + " " + "\(selectedNasiGirl.nameSheIsCalledOrKnownBy)" + " "  + "\(selectedNasiGirl.lastNameOfGirl)"
            
            let toDiscussEmailstring = selectedNasiGirl.emailOfContactWhoKnowsGirl
            let composeVC = MFMailComposeViewController()
            
            composeVC.mailComposeDelegate = self
            // Configure the fields of the interface.
            composeVC.setToRecipients([toDiscussEmailstring])
            composeVC.setSubject(subjectString)
            //composeVC.setMessageBody("XXXXXX", isHTML: false)
          
            self.present(composeVC, animated: true, completion: nil)
              }
    }
    
    @IBAction func callContactToRedd(_ sender: Any) {
        Utility.makeACall(selectedNasiGirl.cellNumberOfContactToReddShidduch)
    }
    
    @IBAction func textContactToRedd(_ sender: Any) {
        if !MFMessageComposeViewController.canSendText() {
            print("SMS services are not available")
        }
        
        let toReddTelString = selectedNasiGirl.cellNumberOfContactToReddShidduch
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
         
        // Configure the fields of the interface.
        composeVC.recipients = [toReddTelString]
        //composeVC.body = "HelloXXXXXXXXXX"
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    @IBAction func emailContactToRedd(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            
            
            let toDiscussEmailstring = selectedNasiGirl.emailOfContactToReddShidduch
            let composeVC = MFMailComposeViewController()
            
            composeVC.mailComposeDelegate = self
            
            
            // Configure the fields of the interface.
            composeVC.setToRecipients([toDiscussEmailstring])
            
 let subject = "Regarding " + "\(selectedNasiGirl.nameSheIsCalledOrKnownBy)" + " " +  "\(selectedNasiGirl.lastNameOfGirl)"
            
            composeVC.setSubject(subject)
            //composeVC.setMessageBody("XXXXXX", isHTML: false)
          
            self.present(composeVC, animated: true, completion: nil)
              }
    }
    
    
    @IBAction func toDiscussWAppTapped(_ sender: Any) {
        whatsAppTheToDisccuss()
    }
    
    
    @IBAction func toReddTapped(_ sender: Any) {
        whatsAppTheToRedd()
    }
    
    @IBAction func girlWappTapped(_ sender: Any) {
        whatsAppTheGirl()
    }
    
    func whatsAppTheToDisccuss(){
        // 1
        let url = "https://wa.me/1"
        // let url2 = "https://wa.me/?text=I'm%20inquiring%20about%20the%20apartment%20lising"
        let number =
        selectedNasiGirl.cellNumberOfContactWhoKNowsGirl
        let urlWhatsAppNumb = url + number
        // 2
        if let urlWhatsAppNumbString = urlWhatsAppNumb.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
          // 3
          if let whatsappURL = NSURL(string: urlWhatsAppNumbString) {
            // 4
            if UIApplication.shared.canOpenURL(whatsappURL as URL) {
              // 5
              UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: nil)
            } else {
              // 6
              print("Cannot Open Whatsapp")
            }
          }
        }
        
    }
    
    func whatsAppTheToRedd(){
        // 1
        let url = "https://wa.me/1"//0195559422"
        let number = selectedNasiGirl.cellNumberOfContactToReddShidduch
        let urlWhats = url + number
        // 2
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
          // 3
          if let whatsappURL = NSURL(string: urlString) {
            // 4
            if UIApplication.shared.canOpenURL(whatsappURL as URL) {
              // 5
              UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: nil)
            } else {
              // 6
              print("Cannot Open Whatsapp")
            }
          }
        }
        
    }
    
    func whatsAppTheGirl() {
        // 1
        let url = "https://wa.me/1"//0195559422"
        let number = selectedNasiGirl.girlsCellNumber
        let urlWhats = url + number
        // 2
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
          // 3
          if let whatsappURL = NSURL(string: urlString) {
            // 4
            if UIApplication.shared.canOpenURL(whatsappURL as URL) {
              // 5
              UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: nil)
            } else {
              // 6
              print("Cannot Open Whatsapp")
            }
          }
        }
    }
    
    
    @IBAction func callTheGirl(_ sender: Any) {
        Utility.makeACall(selectedNasiGirl.girlsCellNumber)
    }
    
    @IBAction func textTheGirl(_ sender: Any) {
        if !MFMessageComposeViewController.canSendText() {
            print("SMS services are not available")
        }
        
        let girlTextString = selectedNasiGirl.girlsCellNumber
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
         
        // Configure the fields of the interface.
        composeVC.recipients = [girlTextString]
        //composeVC.body = "HelloXXXXXXXXXX"
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
        
        }
    
    @IBAction func emailTheGirl(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            
            let girlsEmailString = selectedNasiGirl.girlsEmailAddress
            let composeVC = MFMailComposeViewController()
            
            composeVC.mailComposeDelegate = self
            
            // Configure the fields of the interface.
            composeVC.setToRecipients([girlsEmailString])
           // composeVC.setSubject(subject)
            //composeVC.setMessageBody("XXXXXX", isHTML: false)
          self.present(composeVC, animated: true, completion: nil)
              }

    }
    
}
extension ContactsViewController: MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
   
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        guard let mainView = navigationController?.parent?.view
            else { return }
          
        let hudView = HudView.hud(inView: view, animated: true)
          
        if result.rawValue == 0 {
          // it was cancelled
        }
        if result.rawValue == 1 {
            
        }
        if result.rawValue == 2 {
           // "It was sent"
            hudView.text = "Sent"
        }
        if result.rawValue == 3 {
            // it failed
            hudView.text = "ooops.. failed to send"
        }
        
        self.dismiss(animated: true, completion: nil)
        
        let delayInSeconds = 1.6
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds)
        {
         hudView.hide()
       }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                        didFinishWith result: MessageComposeResult) {
        
        guard let mainView = navigationController?.parent?.view
            else { return }
          
        let hudView = HudView.hud(inView: view, animated: true)
        
        // Check the result or perform other tasks.
        if result.rawValue == 0 {
            //it was cancelled
        }
        if result.rawValue == 1 {
            //it was sent
            hudView.text = "Sent"
        }
        if result.rawValue == 2 {
            //if failed
        }
        
        self.dismiss(animated: true, completion: nil)
        
        let delayInSeconds = 1.6
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds)
        {
        
        hudView.hide()
       
      }
        }
}
   
   
