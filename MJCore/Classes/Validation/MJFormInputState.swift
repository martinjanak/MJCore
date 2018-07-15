//
//  MJFormInputState.swift
//  MJCore
//
//  Created by Martin Janák on 15/07/2018.
//

import Foundation

public enum MJFormInputState: Equatable {
    
    case none
    case valid
    case notValid(String?)
    
    public static func == (lhs: MJFormInputState, rhs: MJFormInputState) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
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
