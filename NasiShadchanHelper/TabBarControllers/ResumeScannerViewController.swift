//
//  ResumeScannerViewController.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 4/26/25.
//  Copyright © 2025 user. All rights reserved.
//

import UIKit
import Vision
import VisionKit
import NaturalLanguage

class ResumeScannerViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var showResultsLabel = UILabel()
    let scanResumeLabel: UILabel = {
        let label = UILabel()
        label.text = "Scan Resume"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    let openCameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Camera", for: .normal)
        
        button.addTarget(self, action: #selector(takePhotoButtonPressed), for: .touchUpInside)
        
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    let resumeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.lightGray.cgColor
        iv.clipsToBounds = true
        
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name: "
        label.font = UIFont.systemFont(ofSize:16)
        return label
    }()
    
    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "Phone: "
        label.font = UIFont.systemFont(ofSize:16)
        return label
    }()
    
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.text = "City: "
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let heightLabel: UILabel = {
        let label = UILabel()
        label.text = "Height: "
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let dobLabel: UILabel = {
        let label = UILabel()
        label.text = "Date of Birth: "
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    

    let recognizedTextLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemGray6
        label.text = "Recognized Text Will Appear Here"
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    let recognizedTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.backgroundColor = .yellow
        tv.text = "Recognized Text Will Appear Here"
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.textAlignment = .left
        //tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = true
        return tv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        
    }
    
    
    
    private func setupLayout() {
        let innerStackView = UIStackView(arrangedSubviews: [resumeImageView,nameLabel])
        innerStackView.axis = .horizontal
        innerStackView.spacing = 10
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.backgroundColor = .red
        
        let stackView =
        UIStackView(arrangedSubviews:
                        [scanResumeLabel,openCameraButton,resumeImageView,
                         nameLabel,phoneLabel,cityLabel,
                         heightLabel,dobLabel,recognizedTextView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .green
        // stackView.alignment = .leading
        view.addSubview(stackView)
        
        //set constraints for stackView
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 40),
                                     stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                                     stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),])
        resumeImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        resumeImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
    }
    @objc  func  takePhotoButtonPressed() {
        
        
        //check if camera is available
        if   UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = true
            //present the camera interface
            present(imagePickerController, animated: true, completion: nil)
        } else {
            //show an alert that camera is not available
            let alert = UIAlertController(title: "Camera Not Available", message: "This device does not support taking photos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
         
    }
    //MARK - UIIMagePickerControllerDelegateMethods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // handle captured image
            processCapturedImage(image)
        }
        // dismiss the image picker
        dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    private func processCapturedImage(_ image: UIImage) {
        self.resumeImageView.image = image
        recognizeText(from: image)
        
    }
    func recognizeText(from image: UIImage) {
        //convert the UIImage to a cgImage
        guard let cIImage = CIImage(image: image) else {return}
        //if no error then process the recognized text
        var recognizedText: String = ""
        var rawRecognizedText: String = ""
        //create request for text recognition
        let request = VNRecognizeTextRequest { (request, error) in
            guard error == nil else {return}
            
            if  let observations = request.results as? [VNRecognizedTextObservation] {
                for observation in observations {
                    guard let topCandidate = observation.topCandidates(1).first else { continue }
                    print("Regonized text:\(topCandidate.string)")
                    recognizedText += topCandidate.string + "\n"
                    
                }
            }
            //update the UI on main thread
            DispatchQueue.main.async {
                print("complete recognized text: \(recognizedText)")
                self.recognizedTextView.text = recognizedText
                let textToExtract = self.recognizedTextLabel.text
                //self.extractEntities(from: textToExtract!)
                //self.extractRegexEntities(from: textToExtract!)
                //self.extractParentNames(from: textToExtract!)
                let name = self.extractFirstPersonName(from: self.recognizedTextView.text)
                let height = self.findHeight(in: self.recognizedTextView)
                
                
                self.nameLabel.text = "Full Name: " + "\(name!)"
                self.heightLabel.text = height
                
                
            }
        }
        //configure the recognition request
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        
        //perform the reqeust on the CIImage
        let handler = VNImageRequestHandler(ciImage: cIImage)
        do {
            try handler.perform([request])
            
        } catch {
            print("failed to perfrom request: \(error)")
        }
    }
    
    /*
     func extractRegexEntities(from text: String) {
     // Define regex patterns for extracting
     //details from the resume
     let namePattern = #"^([A-Z][a-zA-Z\s]+)\n"#
     
     let addressPattern = #"^(|d+\s[A-Za-z0-9\s]+(?:,s?[A-Za-z\s]+)n|s[A-Za-z\s]+\s+|d{5}.$)"#
     let emailPattern = #"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,7}|b"#
     let phonePattern = #"\+?|d{1,3}[-.|s]?|(?|d{1,4}?V?[-.(s]?|d{1,4Jl-.(s]?|d{1,9}"#
     let parentPattern = #"(?i)(Father|Mother):\s([A-Za-z\s]+)"#
     
     
     // Extract the name
     if let nameRegex = try? NSRegularExpression(pattern: namePattern,
     options: [.anchorsMatchLines]) {
     let nameResults = nameRegex.matches (in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
     
     if let nameMatch = nameResults.first {
     let name = String(text[Range(nameMatch.range, in: text)!].trimmingCharacters(in: .whitespacesAndNewlines))
     print ("Name: \(name) ")
     }
     }
     // Extract the address
     if let addressRegex = try?
     NSRegularExpression (pattern: addressPattern, options:
     [.anchorsMatchLines]) {
     let addressResults =
     addressRegex.matches (in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
     if let addressMatch =
     addressResults.first {
     let address = String(text[Range(addressMatch.range, in:
     text)!].trimmingCharacters(in: .whitespacesAndNewlines))
     print ("Address: \(address)")
     }
     }
     
     // Extract the email
     if let emailRegex = try?
     NSRegularExpression(pattern: emailPattern) {
     let emailResults =
     emailRegex.matches(in: text, options: [],
     range: NSRange(location: 0, length: text.utf16.count))
     for emailMatch in emailResults {
     let email =
     String(text[Range(emailMatch.range, in:
     text)!])
     print("Email: \(email)")
     }
     }
     // Extract the phone number
     if let phoneRegex = try?
     NSRegularExpression(pattern: phonePattern) {
     let phoneResults =
     phoneRegex.matches(in: text, options: [],
     range: NSRange(location: 0, length:
     text.utf16.count))
     for phoneMatch in phoneResults {
     let phone =
     String(text[Range(phoneMatch.range, in:
     text)!])
     print ("Phone: \(phone)")
     }
     }
     
     
     // Extract parents' names
     do {
     let parentRegex = try
     NSRegularExpression(pattern: parentPattern,
     options: [])
     let parentResults =
     parentRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
     var fatherName: String?
     var motherName: String?
     
     
     for parentMatch in parentResults {
     if let roleRange =
     Range(parentMatch.range(at: 1), in: text),
     let nameRange =
     Range(parentMatch.range(at: 2), in: text) {
     let parentRole =
     String(text[roleRange])
     let parentName =
     String(text [nameRange])
     //Assign names based on the role
     if parentRole.lowercased () ==
     "father" {
     fatherName = parentName
     }
     else if parentRole.lowercased() ==
     "mother" {
     motherName = parentName
     }
     }
     }
     
     // Update Ul on the main thread
     DispatchQueue.main.async {
     //self.fatherLabel.text = fatherName ??
     //"Not available"
     //self.motherLabel.text =
     // motherName?? "Not available"
     }
     } catch {
     print("Error creating regular expression: \(error)")
     }
     
     }
     */
    /*
     func extractParentNames(from text: String) {
     
     let parentPattern = #"(?i)(Father|Mother):\s([A-Za-z\s]+)"#
     
     // Extract parents' names
     do {
     let parentRegex = try
     NSRegularExpression(pattern: parentPattern,
     options: [])
     let parentResults =
     parentRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
     var fatherName: String?
     var motherName: String?
     
     
     for parentMatch in parentResults {
     if let roleRange =
     Range(parentMatch.range(at: 1), in: text),
     let nameRange =
     Range(parentMatch.range(at: 2), in: text) {
     let parentRole =
     String(text[roleRange])
     let parentName =
     String(text [nameRange])
     //Assign names based on the role
     if parentRole.lowercased () ==
     "father" {
     fatherName = parentName
     }
     else if parentRole.lowercased() ==
     "mother" {
     motherName = parentName
     }
     }
     }
     
     // Update Ul on the main thread
     DispatchQueue.main.async {
     //self.fatherLabel.text = fatherName ??
     //"Not available"
     //self.motherLabel.text =
     // motherName?? "Not available"
     print(fatherName ?? "Not available")
     print(motherName ?? "Not available")
     }
     } catch {
     print("Error creating regular expression: \(error)")
     }
     }
     */
    /*
     func parseParentDetails(from text: String) ->
     (father: String, mother: String) {
     var fatherDetails: String = "'
     var motherDetails: String = ""
     // Split the text into lines for easier
     processing
     let lines = text.components(separatedBy:
     "In")
     var currentParent: String? = nil
     // To keeptrack of which parent we're currently processing
     for line in lines 1
     let trimmedLine =
     line.trimmingCharactersin: whitespacesAnd
     Newlines
     // Check for keywords related to father
     and mother if
     trimmedLine.lowercased().contains("father")
     currentParent = "father"
     fatherDetails += "\n" // Start a new
     line for father details
     } else if
     trimmedLine.lowercased().contains("mother"
     ) 1
     currentParent = "mother"
     motherDetails += "\n" // Start a new
     line for mother details
     } else if let parent = currentParent {
     I Append the line to the current
     narantle Nataile
     currentParent = "father"
     fatherDetails += "\n" // Start a new
     line for tather details
     } else if
     trimmedLine.lowercased().contains("mother"
     currentParent = "mother"
     motherDetails += "\n" // Start a new
     line for mother details
     } else if let parent = currentParent {
     I Append the line to the current
     parent's details
     if parent == "father" {
     fatherDetails += trimmedLine + " "
     } else if parent == "mother" {
     motherDetails += trimmedLine + " "
     /I Trim excess whitespace fatherDetails =
     fatherDetails.trimmingCharacters(in: whitesp aces)
     motherDetails =
     motherDetails.trimmingCharacters(in: whites paces)
     return (fatherDetails, mother Details)
     ｝
     
     */
    func extractEntities(from text: String) {
        
        
        let tagger = NLTagger(tagSchemes:
                                [.nameType])
        //Set the string to analyze
        tagger.string = text
        // Define the range to analyze (entire string in
        
        let range = text.startIndex..<text.endIndex
        // Enumerate through the named entities in the string
        tagger.enumerateTags(in: range,
                             unit: .sentence, scheme: .nameType) { tag, tokenRange in
            if let tag = tag {
                let entity = String(text[tokenRange])
                print ("\(tag.rawValue): \(entity)")
                
                
                
            }
            return true // Keep enumerating
        }
    }
    func extractFirstPersonName(from text:
                                String) -> String? {
        // Regular expression pattern to identify
        //possible first and last names (two capitalized words)
        
        let namePattern = "\\b([A-Z][a-z]+)(?:\\s+([A-Z][a-z]+))?\\s+([A-Z][a-z]+)\\b"
        //let namePattern = "^([\\p{L}]+)(?:\\s+([\\p{L}]+))?\\s+([\\p{L}[-]+]+)$" // Updated regex pattern
        // Create a regex object
        guard let regex = try?
                NSRegularExpression(pattern: namePattern,
                                    options: []) else {return nil}
        //Il Find matches in the input text
        let nsString = text as NSString
        let results = regex.matches(in:text,
                                    options: [], range: NSRange(location: 0, length: nsString.length))
        
        
        
        
        // Check if there is at least one match and
        //return the first one
        if let firstMatch = results.first {
            let firstName = nsString.substring (with:
                                                    firstMatch.range(at: 1)) // First name
            
            print("here are the name results: \(firstName)")
            
            
            let middleName = firstMatch.range(at:
                                                2).location != NSNotFound ?
            nsString.substring(with: firstMatch.range(at:
                                                        2)) + " " : ""
            let lastName = nsString.substring(with:
                                                firstMatch.range(at: 3)) // Last name
            return "\(firstName) \(middleName) \(lastName)".trimmingCharacters(in: .whitespaces)
        }
        return nil
    }
    func findHeight(in textView: UITextView) ->
    String? {
        // Define the regular expression pattern for
        //height
let heightPattern = #"(?:height\s+)?(\d{1,2})\s+ (\d{1,2}|['"][0-9]{1,2}['"])?|(\d{1,2})'(\d{1,2})"#
        //let heightPattern = #"(?:[hH]eight\s:? ?)?([4-6])'?\s(0|1[0-1]|[O-9])?"#
        //I Get the text from the UlTextView
        let text = textView.text ?? ""
        // Create a regular expression object
        guard let regex = try?
                NSRegularExpression (pattern: heightPattern, options: [])
        else {
            print ("Invalid regex pattern")
            return nil
            
            
            
        }
        // Search for matches in the text
        let nsString = text as NSString
        let results = regex.matches (in: text,
                                     options: [], range: NSRange(location: 0, length: nsString.length))
        // If a match is found, return the matched string
        if let match = results.first {
            let matchedString =
            nsString.substring (with: match.range)
            
            
            print("the matched height is \(matchedString)")
            
        
            
            
            return matchedString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
        
    }
    
}

    
         
        
    
        
    
    

