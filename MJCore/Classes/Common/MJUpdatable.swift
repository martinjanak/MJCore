//
//  MJUpdatable.swift
//  MJCore
//
//  Created by Martin Janák on 26/10/2018.
//

import Foundation

public protocol MJUpdatable {
    static func ~~ (lhs: Self, rhs: Self) -> Bool
}

extension MJUpdatable {
    
    static func !~ (lhs: Self, rhs: Self) -> Bool {
        return !(lhs ~~ rhs)
    }
    
}
