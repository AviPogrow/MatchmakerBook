//
//  MainResumeVC.swift
//  NasiShadchanHelper
//
//  Created by apple on 16/11/20.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit
import PDFKit
import Firebase
import MessageUI

class ResumeViewController: UITableViewController {
    
   
    @IBOutlet weak var girlProfileImageView: UIImageView!
    
    @IBOutlet weak var pdfView: PDFView!
    var selectedNasiGirl: NasiGirl!
    
    var documentController : UIDocumentInteractionController!
    

    // set up url session for download
    // so we get delegate call backs
    lazy var downloadsSession: URLSession = {
      let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration,
                             delegate: self,
                             delegateQueue: nil)
      }()
    
    
    var localURL: URL!
    var localImageURL: URL!

    var ref: DatabaseReference!
    var sentSegmentChildArr = [[String : String]]()
    lazy var  subject = selectedNasiGirl.firstNameOfGirl + " " + selectedNasiGirl.lastNameOfGirl + " - Shidduch Information" +
    " - Please confirm receipt"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isUserInteractionEnabled = false
        view.showLoadingIndicator()
        
        self.navigationItem.title =
         selectedNasiGirl.nameSheIsCalledOrKnownBy + " " + selectedNasiGirl.lastNameOfGirl
        downloadDocument()
        downloadProfileImage()
    }
    
    
    @IBAction func sendPhotoWhatsAppTapped(sender: UIButton) {
        
        print("the state of localImageURL is \(self.localImageURL)")
        
        documentController = UIDocumentInteractionController(url:self.localImageURL)
        
        documentController.presentOptionsMenu(from: sender.frame, in: self.view, animated: true)
        
    }
    
    @IBAction func sendResumeWhatsAppTapped (sender: UIButton)  {
       
        
        documentController = UIDocumentInteractionController(url:self.localURL)
        documentController.presentOptionsMenu(from: sender.frame, in: self.view, animated: true)
        
    }
    
    
    @IBAction func emailJustResumeTapped(_ sender: Any) {
        let documentAsImage = drawPDFfromURL(url: localURL)
     let docAsData = documentAsImage?.jpegData(compressionQuality: 0.10)
    if MFMailComposeViewController.canSendMail() {
        let composeVC = MFMailComposeViewController()
        
        composeVC.mailComposeDelegate = self
         
        // Configure the fields of the interface.
        //composeVC.setToRecipients(["address@example.com"])
        composeVC.setSubject(subject)
        //composeVC.setMessageBody("XXXXXX", isHTML: false)
        composeVC.addAttachmentData(docAsData!, mimeType: "image/jpeg", fileName: "girls resume")
        self.present(composeVC, animated: true, completion: nil)
          }
    }
    
    @IBAction func emailJustPhotoTapped(_ sender: Any) {
        
        let selectedGirlProfileImage =  girlProfileImageView.image
         let imageData = selectedGirlProfileImage?.jpegData(compressionQuality: 0.10)
        
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            
            composeVC.mailComposeDelegate = self
             
            // Configure the fields of the interface.
            //composeVC.setToRecipients(["address@example.com"])
            composeVC.setSubject(subject)
            //composeVC.setMessageBody("XXXXXX", isHTML: false)
            composeVC.addAttachmentData(imageData!, mimeType: "image/jpeg", fileName: "girlsPhoto")
            self.present(composeVC, animated: true, completion: nil)
       }
    }
    
    
    @IBAction func emailBothTapped(_ sender: Any) {
        
        
        // 3 sharing items
        // 1 Resume pdf as UIImage
        let documentAsImage = drawPDFfromURL(url: localURL)
     let docAsData = documentAsImage?.jpegData(compressionQuality: 0.10)
       let selectedGirlProfileImage =  girlProfileImageView.image
        let imageData = selectedGirlProfileImage?.jpegData(compressionQuality: 0.10)
        
        // 2 profile image
        //let shareImageURL = localImageURL!
        //let imageData = try! Data(contentsOf: shareImageURL)
        //let imageToShare = UIImage(data: imageData)
        
        
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            
            composeVC.mailComposeDelegate = self
             
            // Configure the fields of the interface.
            //composeVC.setToRecipients(["address@example.com"])
            composeVC.setSubject(subject)
            //composeVC.setMessageBody("HelloXXXXXXXXX", isHTML: false)
            composeVC.addAttachmentData(imageData!, mimeType: "image/jpeg", fileName: "girlsPhoto")
            
            composeVC.addAttachmentData(docAsData!, mimeType: "image/jpeg", fileName: "girls resume")
            self.present(composeVC, animated: true, completion: nil)
      }
    }
    @IBAction func textJustResumeTapped(_ sender: Any) {
        let documentAsImage = drawPDFfromURL(url: localURL)
     let docAsData = documentAsImage?.jpegData(compressionQuality: 0.10)
        
        if !MFMessageComposeViewController.canSendText() {
            print("SMS services are not available")
        }
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
         
        // Configure the fields of the interface.
        //composeVC.recipients = ["3109235682"]
        //composeVC.body = "HelloXXXXXXXXXX"
        
        composeVC.addAttachmentData(docAsData!, typeIdentifier: "public.data", filename: "image.jpeg")
         
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    @IBAction func textJustPhotoTapped(_ sender: Any) {
        
        let selectedGirlProfileImage =  girlProfileImageView.image
         let imageData = selectedGirlProfileImage?.jpegData(compressionQuality: 0.10)
        
        if !MFMessageComposeViewController.canSendText() {
            print("SMS services are not available")
        }
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
         
        // Configure the fields of the interface.
       // composeVC.recipients = ["3109235682"]
       // composeVC.body = "Hello XXXXXXXXXXXX"

        composeVC.addAttachmentData(imageData!, typeIdentifier: "public.data", filename: "image.jpeg")
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    @IBAction func textBothTapped(_ sender: Any) {
        
        let documentAsImage = drawPDFfromURL(url: localURL)
     let docAsData = documentAsImage?.jpegData(compressionQuality: 0.10)
       let selectedGirlProfileImage =  girlProfileImageView.image
        let imageData = selectedGirlProfileImage?.jpegData(compressionQuality: 0.10)
        
        if !MFMessageComposeViewController.canSendText() {
            print("SMS services are not available")
        }
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
         
        // Configure the fields of the interface.
       // composeVC.recipients = ["3109235682"]
       // composeVC.body = "Hello XXXXXXXXXXXX"
        composeVC.addAttachmentData(docAsData!, typeIdentifier: "public.data", filename: "image.jpeg")
        
        composeVC.addAttachmentData(imageData!, typeIdentifier: "public.data", filename: "image.jpeg")
      
         
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    
    func addToSendNode() {
      
        //let ShadchanUserUID = ""
        //"R6w4ccaV1mdnGQV6zndtltfDgWS2"
        let girlsUID = selectedNasiGirl.key
        //"9DD1AFD6-4810-4D73-9(AB5-7FFAADA2DBF9"
        let sendTimeStamp = "\(Date())"
        //sentsSegemntWithTimeStamp
        // get uid for current user
        
        guard let ShadchanUserUID = Auth.auth().currentUser?.uid else { return }
        
       
       let sentResumeNodeRef = Database.database().reference().child("sentsSegemntWithTimeStamp").child(ShadchanUserUID)
        
        let newSendDict = ["timeStamp": sendTimeStamp,
                           "ShadchanUserUID": ShadchanUserUID,
                            "girlsUID": girlsUID]
        
        let ref = sentResumeNodeRef.childByAutoId()
        ref.setValue(newSendDict)
        }
    
    func drawPDFfromURL(url: URL) -> UIImage? {
           guard let document = CGPDFDocument(url as CFURL) else { return nil }
           guard let page = document.page(at: 1) else { return nil }

           let pageRect = page.getBoxRect(.mediaBox)
           let renderer = UIGraphicsImageRenderer(size: pageRect.size)
           let img = renderer.image { ctx in
               UIColor.white.set()
               ctx.fill(pageRect)

               ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
               ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

               ctx.cgContext.drawPDFPage(page)
           }

           return img
       }
   
    /// Get local file path: download task stores tune here; AV player plays it.
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

}
extension ResumeViewController: URLSessionDownloadDelegate {
  
    func downloadDocument() {
        self.pdfView.showLoadingIndicator()
     
        let documentURL = URL(string: selectedNasiGirl.documentDownloadURLString )
        
      let downloadTask = downloadsSession.downloadTask(with: documentURL!)
        
      downloadTask.resume()
    
    }
    
    func downloadProfileImage() {

        let profileImageURL = URL(string: selectedNasiGirl.imageDownloadURLString )
        let downloadTask = downloadsSession.downloadTask(with: profileImageURL!)
     
      downloadTask.resume()
     
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                  didFinishDownloadingTo location: URL) {
      
      let originalURL = downloadTask.originalRequest!.url!
      let downloadType = downloadTask.originalRequest!.url!.pathExtension
    
      print("the download type is \(downloadType)")
      if downloadType == "pdf" {
         localURL = copyFromTempURLToLocalURL(remoteURL: originalURL, location: location)
          
      } else {
        localImageURL = copyFromTempURLToLocalURL(remoteURL: originalURL, location: location)
    }
    
     
        if localURL != nil && localImageURL != nil {
    DispatchQueue.main.async {
        //self.waitingForDataLabel.isHidden = true
        self.setUpPDFView()
        self.setupProfileImageFromLocalURL()
        self.view.isUserInteractionEnabled = true
        self.view.hideLoadingIndicator()
        
        
            }
     }
    
   }
    
    
    func setUpPDFView() {
           
           var document: PDFDocument!
           
           if  let pathURL = localURL {
           document = PDFDocument(url: pathURL)
           }
           
           if let document = document {
               pdfView.displayMode = .singlePageContinuous
               pdfView.autoScales = true
               pdfView.displayDirection = .vertical
               pdfView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
               pdfView.document = document
           }
          self.pdfView.hideLoadingIndicator()
       }
    
    
    func setupProfileImageFromLocalURL() {
         
           if localImageURL != nil {
           
           //let localImageURL = URL(string: localURLAsString)
           let imageData = try! Data(contentsOf: localImageURL!)
           
           let imageFromURl = UIImage(data: imageData)
            self.girlProfileImageView.image = imageFromURl
           }
       }
    
    
    func copyFromTempURLToLocalURL(remoteURL: URL, location: URL) -> URL {
      
        // 1 get the original url we used to download
        // the document from fire base storage
       //let sourceURL = URL(string: selectedSingle.documentDownloadURLString ?? "")!
        
        let sourceURL = remoteURL
       // 2 create a file path pointing to the local
       // document directory
       let destinationURL = localFilePath(for: sourceURL)
       print(destinationURL)
       
       // 3 get the default file manager
       let fileManager = FileManager.default
       
        // clear out the destination url in case something
        // is there
        try? fileManager.removeItem(at: destinationURL)

       do {
         try fileManager.copyItem(at: location, to: destinationURL)
         //download?.track.downloaded = true
       } catch let error {
         print("Could not copy file to disk: \(error.localizedDescription)")
       }

        return destinationURL
        
    }
    
    func localFilePath(for url: URL) -> URL {
         return documentsPath.appendingPathComponent(url.lastPathComponent)
       }
}

extension ResumeViewController: MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
   
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        guard let mainView = navigationController?.parent?.view
            else { return }
          
        var hudView:HudView!
          
        if result.rawValue == 0 {
          // it was cancelled
        }
        
        if result.rawValue == 1 {
            
        }
        
        if result.rawValue == 2 {
           // "It was sent"
             hudView = HudView.hud(inView: view, animated: true)
            hudView.text = "Sent"
            addToSendNode()
         }
        if result.rawValue == 3 {
            // it failed
            hudView = HudView.hud(inView: view, animated: true)
            hudView.text = "ooops.. failed to send"
        }
        
        self.dismiss(animated: true, completion: nil)
        
        let delayInSeconds = 1.6
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds)
        {
        
            if hudView != nil {
                hudView.hide()
                
            }
       
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
            addToSendNode()
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
   
   
   
