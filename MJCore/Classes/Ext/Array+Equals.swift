//
//  Array+Equals.swift
//  MJCore
//
//  Created by Martin Janák on 01/08/2018.
//

import Foundation

infix operator === : DefaultPrecedence

extension Array where Element: Equatable {
    
    public static func ===(left: Array<Element>, right: Array<Element>) -> Bool {
        guard left.count == right.count else {
            return false
        }
        for i in 0..<left.count {
            if left[i] != right[i] {
                return false
            }
        }
        return true
    }
    
}
