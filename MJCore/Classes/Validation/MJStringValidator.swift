//
//  StringValidator.swift
//  MJCore
//
//  Created by Martin Janák on 14/07/2018.
//

import Foundation

public enum MJStringValidator {
    
    case wrapper((String) -> Bool)
    case regex(String)
    case minChars(Int)
    
    public var closure: (String) -> Bool {
        switch self {
        case .wrapper(let validator):
            return validator
        case .regex(let regexString):
            return { value in
                let test = NSPredicate(format:"SELF MATCHES[c] %@", regexString)
                return test.evaluate(with: value)
            }
        case .minChars(let count):
            return { value in
                value.count >= count
            }
        }
    }
    
}

extension MJStringValidator {
    
    public static func &&(left: MJStringValidator, right: MJStringValidator) -> MJStringValidator {
        return .wrapper({ value in
            return left.closure(value) && right.closure(value)
        })
    }
    
    public static func ||(left: MJStringValidator, right: MJStringValidator) -> MJStringValidator {
        return .wrapper({ value in
            return left.closure(value) || right.closure(value)
        })
    }
    
}
