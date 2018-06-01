//
//  Date+Ext.swift
//  MJCore
//
//  Created by Martin Janák on 20/05/2018.
//

import Foundation

public enum MJDateError: Error {
    case wrongFormat(iso: String, options: ISO8601DateFormatter.Options)
}

extension Date {
    
    // MARK: Strings
    
    public func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // MARK: ISO
    
    public static func create(
        fromIso: String,
        additionalOptions: ISO8601DateFormatter.Options? = nil
    ) throws -> Date {
        if let date = createOptional(
            fromIso: fromIso,
            additionalOptions: additionalOptions
        ) {
            return date
        } else {
            throw MJDateError.wrongFormat(iso: fromIso, options: additionalOptions ?? [])
        }
    }
    
    public static func createOptional(
        fromIso: String,
        additionalOptions: ISO8601DateFormatter.Options? = nil
    ) -> Date? {
        let formatter = ISO8601DateFormatter()
        var options: ISO8601DateFormatter.Options = [.withInternetDateTime]
        if let additionalOptions = additionalOptions {
            options.formUnion(additionalOptions)
        }
        formatter.formatOptions = options
        return formatter.date(from: fromIso)
    }
    
    public func getIso(additionalOptions: ISO8601DateFormatter.Options? = nil) -> String {
        let formatter = ISO8601DateFormatter()
        var options: ISO8601DateFormatter.Options = [.withInternetDateTime]
        if let additionalOptions = additionalOptions {
            options.formUnion(additionalOptions)
        }
        formatter.formatOptions = options
        return formatter.string(from: self)
    }
    
    // MARK: Unix epoch time
    
    public static func create(fromEpochTime: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(fromEpochTime))
    }
    
    public func getEpochTime() -> Int {
        return Int(self.timeIntervalSince1970)
    }
    
    // MARK: Util
    
    public func minutes(from date: Date) -> Int? {
        return Calendar.current.dateComponents(Set<Calendar.Component>([.minute]), from: date, to: self).minute
    }
    
}
