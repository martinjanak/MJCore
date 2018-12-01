//
//  MJPredicate.swift
//  MJCore
//
//  Created by Martin Janák on 07/06/2018.
//

import CoreData

public enum MJCoreDataFilterError: Error {
    case valueMismatch
}

public enum MJCoreDataFilter {

    case wrapper(NSPredicate)
    case equal(String, Any)
    case notEqual(String, Any)
    case greater(String, Any)
    case less(String, Any)
    case greaterOrEqual(String, Any)
    case lessOrEqual(String, Any)
    
    var predicate: NSPredicate? {
        switch self {
        case .equal(let key, let value):
            return createPredicate(left: "\(key) ==", anyValue: value)
        case .notEqual(let key, let value):
            return createPredicate(left: "\(key) !=", anyValue: value)
        case .greater(let key, let value):
            return createPredicate(left: "\(key) >", anyValue: value)
        case .less(let key, let value):
            return createPredicate(left: "\(key) <", anyValue: value)
        case .greaterOrEqual(let key, let value):
            return createPredicate(left: "\(key) >=", anyValue: value)
        case .lessOrEqual(let key, let value):
            return createPredicate(left: "\(key) <=", anyValue: value)
        case .wrapper(let predicate):
            return predicate
        }
    }
    
    private func createPredicate(left: String, anyValue: Any) -> NSPredicate? {
        var varArg: CVarArg
        if let value = anyValue as? Bool {
            varArg = NSNumber(value: value)
        } else if let value = anyValue as? Date {
            varArg = value as NSDate
        } else if let value = anyValue as? CVarArg {
            varArg = value
        } else {
            return nil
        }
        return NSPredicate(format: "\(left) %@", varArg)
    }
    
}

extension MJCoreDataFilter {
    
    public static func &&(left: MJCoreDataFilter, right: MJCoreDataFilter) -> MJCoreDataFilter? {
        guard let leftPredicate = left.predicate,
            let rightPredicate = right.predicate else {
            return nil
        }
        return .wrapper(
            NSCompoundPredicate(
                type: .and,
                subpredicates: [
                    leftPredicate,
                    rightPredicate
                ]
            )
        )
    }
    
    public static func ||(left: MJCoreDataFilter, right: MJCoreDataFilter) -> MJCoreDataFilter? {
        guard let leftPredicate = left.predicate,
            let rightPredicate = right.predicate else {
            return nil
        }
        return .wrapper(
            NSCompoundPredicate(
                type: .or,
                subpredicates: [
                    leftPredicate,
                    rightPredicate
                ]
            )
        )
    }
    
}
