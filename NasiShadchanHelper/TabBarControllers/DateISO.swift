//
//  DateISO.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 2/24/26.
//  Copyright © 2026 user. All rights reserved.
//

import Foundation

enum ISODateOnly {
    static func isISO(_ s: String) -> Bool {
        s.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil
    }

    /// "yyyy-MM-dd" -> Date at noon local (safe for DateRow)
    static func dateForDateRow(fromISO iso: String) -> Date? {
        let parts = iso.split(separator: "-")
        guard parts.count == 3,
              let y = Int(parts[0]),
              let m = Int(parts[1]),
              let d = Int(parts[2]) else { return nil }

        var comps = DateComponents()
        comps.year = y
        comps.month = m
        comps.day = d
        comps.hour = 12
        return Calendar.current.date(from: comps)
    }

    /// Date -> "yyyy-MM-dd" using the local calendar day (no time component stored)
    static func iso(from date: Date) -> String {
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month, .day], from: date)
        guard let y = c.year, let m = c.month, let d = c.day else { return "" }
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    /// Legacy "yy/MM/dd" like "03/02/08" -> ISO using plausible-age pivot.
    static func isoFromLegacyYYMMDD(_ s: String, today: Date = Date(), minAge: Int = 16, maxAge: Int = 80) -> String? {
        let parts = s.split(separator: "/")
        guard parts.count == 3,
              let yy = Int(parts[0]),
              let mm = Int(parts[1]),
              let dd = Int(parts[2]) else { return nil }

        let candidateYears = [1900 + yy, 2000 + yy]
        let cal = Calendar.current

        func ageFor(year: Int) -> Int? {
            var comps = DateComponents()
            comps.year = year
            comps.month = mm
            comps.day = dd
            comps.hour = 12
            guard let dob = cal.date(from: comps) else { return nil }
            return cal.dateComponents([.year], from: dob, to: today).year
        }

        let plausible = candidateYears.compactMap { year -> (year: Int, age: Int)? in
            guard let age = ageFor(year: year) else { return nil }
            return (year, age)
        }.filter { $0.age >= minAge && $0.age <= maxAge }

        if let best = plausible.sorted(by: { $0.age < $1.age }).first {
            return String(format: "%04d-%02d-%02d", best.year, mm, dd)
        }

        // fallback: most profiles are modern
        return String(format: "%04d-%02d-%02d", 2000 + yy, mm, dd)
    }

    /// Accept ISO already, or legacy yy/MM/dd, or 4-digit slash formats; return ISO if possible.
    static func normalizeToISO(_ raw: String) -> String? {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return nil }
        if isISO(s) { return s }

        // legacy yy/MM/dd (your old storage)
        if s.range(of: #"^\d{2}/\d{2}/\d{2}$"#, options: .regularExpression) != nil {
            return isoFromLegacyYYMMDD(s)
        }

        // 4-digit variants
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)

        for fmt in ["yyyy/MM/dd", "MM/dd/yyyy", "dd/MM/yyyy"] {
            df.dateFormat = fmt
            if let d = df.date(from: s) { return iso(from: d) }
        }

        return nil
    }
    /// Display format that matches Eureka's default DateRow style (e.g. "Feb 26, 2026")
    static let eurekaDisplayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
    static func displayStringForDOB(_ rawDOB: String) -> String {
        guard let iso = normalizeToISO(rawDOB),
              let date = dateForDateRow(fromISO: iso) else { return "" }
        return eurekaDisplayFormatter.string(from: date)
    }
}
