//
//  ScannerViewController.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 7/19/25.
//  Copyright © 2025 user. All rights reserved.
//
import UIKit
import VisionKit
import Vision
import NaturalLanguage

protocol ScannerViewControllerDelegate {
    func didScanAndParseResume(dict: [String: String])
}


class ScannerViewController: UITableViewController, VNDocumentCameraViewControllerDelegate{
    
    var firstName = ""
    var  lastName = ""
    var  dob = ""
    var  city = ""
    var  telephone = ""
    var  height = ""
    
    var showResultsLabel = UILabel()
    let scanResumeLabel: UILabel = {
        let label = UILabel()
        label.text = "Scan Resume"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.backgroundColor = .lightText
        return label
    }()
    
    let saveParsedDataButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Parsed Data", for: .normal)
        
        button.addTarget(self, action: #selector(saveParsedData), for: .touchUpInside)
        
        button.backgroundColor = .green
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    let openCameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Document Scanner", for: .normal)
        
        button.addTarget(self, action: #selector(presentDocumentScanner), for: .touchUpInside)
        
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let resumeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .lightText
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.lightGray.cgColor
        iv.clipsToBounds = true
        
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name: "
        label.font = UIFont.systemFont(ofSize:16)
        label.backgroundColor = .white
        return label
    }()
    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "Phone: "
        label.font = UIFont.systemFont(ofSize:16)
        label.backgroundColor = .white
        return label
    }()
    
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.text = "City: "
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = .white
        return label
    }()
    
    private let heightLabel: UILabel = {
        let label = UILabel()
        label.text = "Height: "
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = .white
        return label
    }()
    
    private let dobLabel: UILabel = {
        let label = UILabel()
        label.text = "Date of Birth: "
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = .white
        return label
    }()
    
    
    let recognizedTextLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemGray6
        label.text = "OCR Text Will Appear Here"
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    let recognizedTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.backgroundColor = .black
        tv.textColor = .white
        tv.text = "OCR Text Will Appear Here"
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.textAlignment = .left
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = true
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerView = createLargeHeaderView()
        tableView.tableHeaderView = headerView
        
    }
    
    var delegate: ScannerViewControllerDelegate?
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        print("Scanned: \(scan)")
        var scannedImages: [UIImage] = []
        for pageIndex in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageIndex)
            self.resumeImageView.image = image
            recognizeText(from: image)
        }
        dismiss(animated: true)
    }
    
    
    @objc func saveParsedData() {
     

        
        let parsedGirlDictionary: [String: String] = ["firstName": self.firstName, "lastName": self.lastName, "dob": self.dob, "city": self.city, "telephone": self.telephone, "height": self.height]
        
        self.delegate?.didScanAndParseResume(dict: parsedGirlDictionary)
        self.navigationController?.popViewController(animated: true)
    }
    
    func recognizeText(from image: UIImage) {
        
        guard let cIImage = CIImage(image: image) else {return}
        var recognizedText: String = ""
        var rawRecognizedText: String = ""
        var girlsName: String = ""
       
        let request = VNRecognizeTextRequest { (request, error) in
            guard error == nil else {return}
            let topLine  = request.results?.first as? VNRecognizedTextObservation
            let string = topLine?.topCandidates(1).first?.string
            print("THE TOP LINE IS \(string!)")
            //girlsName = string!
            
            let textObservations = request.results as? [VNRecognizedTextObservation]
            var count = 0
            for textObservation in textObservations ?? [] {
                
                if count >= 8 {break}
                
                let topCandidate = textObservation.topCandidates(1).first
                let stringVersion = topCandidate?.string
                
                rawRecognizedText += stringVersion! + "\n"
                print("THE Raw TEXt IS \(rawRecognizedText)")
                count += 1
            }
            girlsName = self.extractName(from: rawRecognizedText) ?? ""
            var splitName = self.splitLineIntoFirstAndLastName(girlsName) ?? ("","")
            self.firstName = splitName.0
            self.lastName = splitName.1
            self.dob = self.extractDateOfBirth(from: rawRecognizedText) ?? ""
            self.city  = self.extractCity(from: rawRecognizedText) ?? ""
            self.telephone = self.extractNormalizedPhoneNumber(from: rawRecognizedText) ?? ""
            //self.height = self.extractHeight(from: rawRecognizedText) ?? ""
            self.height = self.extractFeetInches(from: rawRecognizedText) ?? ""
        
          }
        
        //update the UI on main thread
        DispatchQueue.main.async { [self] in
            print("complete recognized text: \(recognizedText)")
            self.recognizedTextView.text = "OCR Text:" + "\n" + rawRecognizedText
            self.nameLabel.text = "Name: " + firstName + " " + lastName
            self.dobLabel.text = "Date of Birth: " + dob
            self.cityLabel.text = "City: " + city
            self.phoneLabel.text = "Telephone: " + telephone
            self.heightLabel.text = "Height: " + height
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
    
    
    
    @objc func presentDocumentScanner() {
        guard VNDocumentCameraViewController.isSupported else { return }
        let scannerVC =
        VNDocumentCameraViewController()
        scannerVC.delegate = self
        present(scannerVC, animated: true, completion: nil)
    }
    /*
    private func setupLayout() {
        let innerStackView = UIStackView(arrangedSubviews: [resumeImageView,nameLabel])
        innerStackView.axis = .horizontal
        innerStackView.spacing = 10
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.backgroundColor = .red
        
        let stackView =
        UIStackView(arrangedSubviews:
                        [scanResumeLabel,saveParsedDataButton,openCameraButton,resumeImageView,
                         nameLabel,phoneLabel,cityLabel,
                         heightLabel,dobLabel,recognizedTextView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .systemCyan
        // stackView.alignment = .leading
        //stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        //set constraints for stackView
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 40),
                                     stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                                     stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),])
        resumeImageView.heightAnchor.constraint(equalToConstant: 450).isActive = true
        resumeImageView.widthAnchor.constraint(equalToConstant: 180).isActive = true
        recognizedTextView.heightAnchor.constraint(equalToConstant: 700).isActive = true
        
        
    }
    
    */
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 850
        } else {
            return 100
        }
    }
    
    /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            
            
            let header = UIView()
            header.backgroundColor = .lightText
            
            
            let stackView =
            UIStackView(arrangedSubviews:
                            [saveParsedDataButton,scanResumeLabel,openCameraButton,resumeImageView,
                             nameLabel,phoneLabel,cityLabel,
                             heightLabel,dobLabel,recognizedTextView])
            stackView.axis = .vertical
            stackView.spacing = 20
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.backgroundColor = .secondaryLabel
            stackView.distribution = .fill
            // stackView.alignment = .leading
            header.addSubview(stackView)
            
            //set constraints for stackView
            NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: header.topAnchor, constant: 10),stackView.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
                                         stackView.leadingAnchor.constraint(equalTo:header.leadingAnchor, constant: 20),
                                         stackView.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20),])
            resumeImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            resumeImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            
            return header
        } else {
            return UIView()
        }
    }
    */
    func createLargeHeaderView() -> UIView {
        let header = UIView()
        header.backgroundColor = .white
        let stackView =
        UIStackView(arrangedSubviews:
                        [saveParsedDataButton,scanResumeLabel,openCameraButton,resumeImageView,
                         nameLabel,phoneLabel,cityLabel,
                         heightLabel,dobLabel,recognizedTextView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.distribution = .fill
        // stackView.alignment = .leading
        header.addSubview(stackView)
        
        //set constraints for stackView
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: header.topAnchor, constant: 10),stackView.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
                                     stackView.leadingAnchor.constraint(equalTo:header.leadingAnchor, constant: 20),
                                     stackView.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20),])
        resumeImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        resumeImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        header.frame.size.height = 900
        return header
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "test"
        return cell
        
    }
    // override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //      return section == 0 ? 0 : 1
    // }
    
    func extractHeight(from text: String) -> String? {
        // Regex for heights like 5'8", 5' 8, 5 ft 8 in, 5ft8
        let pattern = #"\b(\d)\s?(?:'|ft)\s?(\d{1,2})?\s?(?:\"|in|inch|inches)?\b"#

        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            if let match = regex.firstMatch(in: text, options: [], range: range) {
                if let heightRange = Range(match.range, in: text) {
                    return String(text[heightRange])
                }
            }
        }

        return nil
    }
    
    func extractName(from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // Find the first line that doesn't look like DOB, phone, or address
        for line in lines {
            if !line.lowercased().contains("dob"),
               !line.contains("@"),
               (line.range(of: "\\d", options: .regularExpression) == nil) { // no numbers
                return line
            }
        }

        return nil
    }
    
    // takes a line of string text and splits it
    func splitLineIntoFirstAndLastName(_ line: String) -> (first: String, last: String)? {
        let parts = line.split(separator: " ")
        guard parts.count > 1 else { return nil }
        
        var firstName: String = ""
        var lastName: String = ""
        
        for (index, part) in parts.enumerated() {
            if index == 0 {
                firstName = String(part)
            }
            if index == 1 {
                lastName = String(part)
            }
        }
        return (first: firstName, last: lastName)
    }
    /*
    func extractName(from text: String) -> String? {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text

        var fullName: String?
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                             unit: .word,
                             scheme: .nameType,
                             options: [.omitPunctuation, .omitWhitespace]) { tag, range in
            if tag == .personalName {
                let fullName = String(text[range])
                //fullName = detectedName.components(separatedBy: " ").first
                return false // Stop after the first name
            }
            return true
        }
        return fullName
    }
    */
   func extractNormalizedPhoneNumber(from text: String) -> String? {
    do {
        let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = detector.matches(in: text, options: [], range: range)

        if let match = matches.first,
           let phoneNumber = match.phoneNumber {

            // Remove all non-numeric characters
            var digits = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

            // If it's a US number without country code, add +1
            //if digits.count == 10 {
            //    digits = "1" + digits
           // }

            // Return normalized format
            return "\(digits)"
        }
    } catch {
        print("Error creating phone number detector: \(error)")
    }

    return nil
}
    func extractDateOfBirth(from text: String) -> String? {
        // 1. First, try using NSDataDetector for full dates
        if let detectedDate = detectFullDate(from: text) {
            return detectedDate
        }

        // 2. Fallback: Check for Month + Year (e.g. "June 1995")
        if let monthYear = detectMonthYear(from: text) {
            return monthYear
        }

        // 3. Fallback: Check for Year only (e.g. "1995")
        if let yearOnly = detectYearOnly(from: text) {
            return yearOnly
        }

        return nil
    }
    
    

   
    /// Returns a canonical ASCII string: e.g., "5'7\"" or nil if not found.
    func extractFeetInches(from text: String) -> String? {
        // ([4-6]) → feet 4..6
        // \D+     → one or more non-digits between
        // (1[01]|[0-9]) → inches 0..11 (no leading zeros)
        let pattern = #"(?<!\d)\b([4-6])\b\D+(1[01]|[0-9])\b(?!\d)"#

        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let nsrange = NSRange(text.startIndex..<text.endIndex, in: text)

        guard let m = regex.firstMatch(in: text, range: nsrange),
              let feetRange = Range(m.range(at: 1), in: text),
              let inchRange = Range(m.range(at: 2), in: text),
              let feet = Int(text[feetRange]),
              let inches = Int(text[inchRange]) else {
            return nil
        }

        // Canonical output: 5'7"
        return "\(feet)'\(inches)\""
    }


    
    
    
    
    //MARK - extract city and state
    func extractCity(from text: String) -> String? {
        do {
            // Create a detector for addresses
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.address.rawValue)
            let range = NSRange(location: 0, length: text.utf16.count)
            let matches = detector.matches(in: text, options: [], range: range)

            if let match = matches.first,
               let components = match.addressComponents {
                let city = components[NSTextCheckingKey.city]
                //let state = components[NSTextCheckingKey.state]
                return city
            }
        } catch {
            print("Error creating address detector: \(error)")
        }

        return nil
    }
    
    
    //MARK - step 1: detect full date of birth
    func detectFullDate(from text: String) -> String? {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
            
            let range = NSRange(location: 0, length: text.utf16.count)
            let matches = detector.matches(in: text, options: [], range: range)
            
            if let date = matches.first?.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.string(from: date)
            }
        }  catch {
            print("error creatig date \(error)")
        }
        return nil
    }
    // MARK: - step 2: Month + year (e.g. " June 1995)
    private func detectMonthYear(from text: String) -> String? {
        let months = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    for month in months {
    if let range = text.range(of: "\(month) \\d{4}", options: .regularExpression) {
        let match = String(text[range])
        let parts = match.split(separator: " ")
        if  parts.count == 2, let year = Int(parts[1]) {
            let monthIndex = months.firstIndex(of: month)! + 1
            return String(format:"%04d-%02d", year, monthIndex)
        }
       }
    }
        return nil
    }
    //MARK: - Step 3 Year only
    private func detectYearOnly(from text: String) -> String? {
    guard let range = text.range(of: "\\b(19|20)\\d{2}\\b", options: .regularExpression) else {return nil }
        return String(text[range])
    }
}






