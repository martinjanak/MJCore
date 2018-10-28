//
//  MJUpdatable.swift
//  MJCore
//
//  Created by Martin Janák on 26/10/2018.
//

import Foundation

public protocol MJUpdatable {
    var updateSignature: String { get }
}

extension MJUpdatable {
    
    public static func ~~ (lhs: Self, rhs: Self) -> Bool {
        return lhs.updateSignature == rhs.updateSignature
    }
    
    public static func !~ (lhs: Self, rhs: Self) -> Bool {
        return !(lhs ~~ rhs)
    }
    
}
