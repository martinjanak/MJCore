//
//  MJPredicate.swift
//  MJCore
//
//  Created by Martin Janák on 07/06/2018.
//

import CoreData


public enum MJCoreDataFilter {

    case wrapper(NSPredicate)
    case int(String, Int)
    case string(String, String)
    case bool(String, Bool)
    case date(String, Date)
    
    var predicate: NSPredicate {
        switch self {
        case .wrapper(let predicate):
            return predicate
        case .int(let left, let value):
            return createPredicate(left: left, value: value)
        case .string(let left, let value):
            return createPredicate(left: left, value: value)
        case .bool(let left, let value):
            return createPredicate(left: left, value: NSNumber(value: value))
        case .date(let left, let date):
            return createPredicate(left: left, value: date as NSDate)
        }
    }
    
    private func createPredicate(left: String, value: CVarArg) -> NSPredicate {
        return NSPredicate(format: "\(left) %@", value)
    }
    
}

extension MJCoreDataFilter {
    
    public static func &&(left: MJCoreDataFilter, right: MJCoreDataFilter) -> MJCoreDataFilter {
        return .wrapper(
            NSCompoundPredicate(
                type: .and,
                subpredicates: [
                    left.predicate,
                    right.predicate
                ]
            )
        )
    }
    
    public static func ||(left: MJCoreDataFilter, right: MJCoreDataFilter) -> MJCoreDataFilter {
        return .wrapper(
            NSCompoundPredicate(
                type: .or,
                subpredicates: [
                    left.predicate,
                    right.predicate
                ]
            )
        )
    }
    
}
