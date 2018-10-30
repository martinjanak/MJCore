//
//  MJGroupElementType.swift
//  MJCore
//
//  Created by Martin Janák on 30/10/2018.
//

import Foundation

public protocol MJGroupElementType {
    var uniqueId: String { get }
    var updateSignature: String { get }
}

extension MJGroupElementType {
    
    public var uniqueIdType: String {
        return "\(Self.self)-" + uniqueId
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uniqueIdType == rhs.uniqueIdType
    }
    
    public static func != (lhs: Self, rhs: Self) -> Bool {
        return !(lhs == rhs)
    }
    
    public static func ~~ (lhs: Self, rhs: Self) -> Bool {
        return lhs.updateSignature == rhs.updateSignature
    }
    
    public static func !~ (lhs: Self, rhs: Self) -> Bool {
        return !(lhs ~~ rhs)
    }
    
    public var totalId: String {
        return "\(uniqueIdType)\(updateSignature)"
    }
    
}
