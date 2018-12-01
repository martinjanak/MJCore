//
//  MJFormInputState.swift
//  MJCore
//
//  Created by Martin Janák on 15/07/2018.
//

import Foundation

public enum MJValidityState: Equatable {
    
    case notSpecified
    case valid
    case notValid(String?)
    
    public static func == (lhs: MJValidityState, rhs: MJValidityState) -> Bool {
        switch (lhs, rhs) {
        case (.notSpecified, .notSpecified):
            return true
        case (.valid, .valid):
            return true
        case (.notValid(let textLeft), .notValid(let textRight)):
            return textLeft == textRight
        default:
            return false
        }
    }
    
}
