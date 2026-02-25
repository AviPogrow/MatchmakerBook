//
//  Untitled 2.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 2/21/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation

struct ResumeParser {

    // Main entry point
    func parse(text: String) -> [String: String] {
        let nameLine = extractName(from: text) ?? ""
        let split = splitFirstEverythingLast(nameLine) ?? ("","")

        let firstName = split.0
        let lastName  = split.1
        let dob       = extractDateOfBirth(from: text) ?? ""
        let city      = extractCity(from: text) ?? ""
        let telephone = extractNormalizedPhoneNumber(from: text) ?? ""
        let height    = extractFeetInches(from: text) ?? ""
        let heightInInches = totalInches(from: height).map(String.init) ?? ""

        return [
            "firstName": firstName,
            "lastName": lastName,
            "dob": dob,
            "city": city,
            "telephone": telephone,
            "height": height,
            "heightInInches": heightInInches
        ]
    }

    // MARK: - Name

    func extractName(from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for line in lines {
            if !line.lowercased().contains("dob"),
               !line.lowercased().contains("date of birth"),
               !line.contains("@"),
               (line.range(of: "\\d", options: .regularExpression) == nil) {
                return line
            }
        }
        return nil
    }

    func splitFirstEverythingLast(_ line: String) -> (String, String)? {
        let cleaned = line
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[()]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: ",;:"))

        var parts = cleaned.split(separator: " ").map(String.init)
        guard parts.count >= 2 else { return nil }

        let last = parts.removeLast()
        let first = parts.joined(separator: " ")
        return (first, last)
    }

    // MARK: - Phone

    func extractNormalizedPhoneNumber(from text: String) -> String? {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let range = NSRange(location: 0, length: text.utf16.count)
            let matches = detector.matches(in: text, options: [], range: range)

            if let match = matches.first, let phoneNumber = match.phoneNumber {
                let digits = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                return digits
            }
        } catch { }
        return nil
    }

    // MARK: - City

    func extractCity(from text: String) -> String? {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.address.rawValue)
            let range = NSRange(location: 0, length: text.utf16.count)
            let matches = detector.matches(in: text, options: [], range: range)

            if let match = matches.first,
               let components = match.addressComponents {
                return components[NSTextCheckingKey.city]
            }
        } catch { }
        return nil
    }

 // MARK: - DOB
 func extractDateOfBirth(from text: String) -> String? {
     if let detected = detectFullDate(from: text) { return detected }
     if let monthYear = detectMonthYear(from: text) { return monthYear }
     if let yearOnly = detectYearOnly(from: text) { return yearOnly }
     return nil
 }

 private func detectFullDate(from text: String) -> String? {
     do {
         let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
         let range = NSRange(location: 0, length: text.utf16.count)
         let matches = detector.matches(in: text, options: [], range: range)

         if let date = matches.first?.date {
             // ✅ always return ISO date-only
             return ISODateOnly.iso(from: date)
         }
     } catch { }
     return nil
 }

 private func detectMonthYear(from text: String) -> String? {
     let months = ["January","February","March","April","May","June","July","August","September","October","November","December"]

     for (idx, month) in months.enumerated() {
         if let range = text.range(of: "\(month) \\d{4}", options: .regularExpression) {
             let match = String(text[range]) // "June 1995"
             let parts = match.split(separator: " ")
             guard parts.count == 2, let year = Int(parts[1]) else { continue }

             let monthNumber = idx + 1
             // ✅ ISO output (pick day=1 since only month+year known)
             return String(format: "%04d-%02d-%02d", year, monthNumber, 1)
         }
     }
     return nil
 }

 private func detectYearOnly(from text: String) -> String? {
     guard let range = text.range(of: "\\b(19|20)\\d{2}\\b", options: .regularExpression) else { return nil }
     let yearString = String(text[range])
     guard let year = Int(yearString) else { return nil }

     // ✅ ISO output (pick June 1 since only year known)
     return String(format: "%04d-%02d-%02d", year, 6, 1)
 }
 
   
    // MARK: - Height

    /// Returns canonical ASCII string like `5'7"` or nil.
    func extractFeetInches(from text: String) -> String? {
        let pattern = #"(?<!\d)\b([4-6])\b\D+(1[01]|[0-9])\b(?!\d)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let nsrange = NSRange(text.startIndex..<text.endIndex, in: text)

        guard let m = regex.firstMatch(in: text, range: nsrange),
              let feetRange = Range(m.range(at: 1), in: text),
              let inchRange = Range(m.range(at: 2), in: text),
              let feet = Int(text[feetRange]),
              let inches = Int(text[inchRange])
        else { return nil }

        return "\(feet)'\(inches)\""
    }

    private func totalInches(from height: String) -> Int? {
        guard !height.isEmpty else { return nil }

        let cleaned = height
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "”", with: "\"")
            .replacingOccurrences(of: "“", with: "\"")

        let pattern = #"(\d)'\s*(\d{1,2})"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned)),
              let feetRange = Range(match.range(at: 1), in: cleaned),
              let inchRange = Range(match.range(at: 2), in: cleaned),
              let feet = Int(cleaned[feetRange]),
              let inches = Int(cleaned[inchRange])
        else { return nil }

        return feet * 12 + inches
    }
}
