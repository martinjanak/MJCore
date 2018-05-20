//
//  Date+Ext.swift
//  MJCore
//
//  Created by Martin Janák on 20/05/2018.
//

import Foundation

public enum MJDateError: Error {
    case wrongIsoFormat
}

extension Date {
    
    // MARK: Strings
    
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // MARK: ISO
    
    static func create(fromIso: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: fromIso) {
            return date
        } else {
            throw MJDateError.wrongIsoFormat
        }
    }
    
    static func createOptional(fromIso: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: fromIso)
    }
    
    func getIso() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
    
    // MARK: Unix epoch time
    
    static func create(fromEpochTime: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(fromEpochTime))
    }
    
    func getEpochTime() -> Int {
        return Int(self.timeIntervalSince1970)
    }
    
    // MARK: Util
    
    func minutes(from date: Date) -> Int? {
        return Calendar.current.dateComponents(Set<Calendar.Component>([.minute]), from: date, to: self).minute
    }
    
}
