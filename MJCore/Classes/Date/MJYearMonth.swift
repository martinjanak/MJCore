//
//  MJYearMonth.swift
//  MJCore
//
//  Created by Martin Janák on 12/07/2018.
//

import Foundation

public struct MJYearMonth: Comparable, Hashable {
    
    public let year: Int
    public let month: MJMonth
    
    public init(year: Int, month: MJMonth) {
        self.year = year
        self.month = month
    }
    
    public init(year: Int, monthNumber: Int) {
        self.year = year
        self.month = MJMonth(rawValue: monthNumber) ?? .january
    }
    
    public init(date: Date) {
        let comps = Calendar.current.dateComponents([.year, .month], from: date)
        self.year = comps.year ?? 2000
        let monthNumber = comps.month ?? 1
        self.month = MJMonth(rawValue: monthNumber) ?? .january
    }
    
    public var hashValue: Int {
        return year * 12 + month.rawValue
    }
    
    public func firstDay() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month.rawValue
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
    
    public func add(_ months: Int) -> MJYearMonth {
        let date = firstDay()
        return MJYearMonth(
            date: Calendar.current.date(byAdding: .month, value: months, to: date) ?? Date()
        )
    }
    
    public func lastDay() -> Date {
        return Calendar.current.date(
            byAdding: DateComponents(month: 1, day: -1),
            to: firstDay()
        )  ?? Date()
    }
    
    public static func == (lhs: MJYearMonth, rhs: MJYearMonth) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month
    }
    
    public static func < (lhs: MJYearMonth, rhs: MJYearMonth) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        } else {
            return lhs.month.rawValue < rhs.month.rawValue
        }
    }
    
    public static var current: MJYearMonth {
        return Date().yearMonth
    }
    
}
