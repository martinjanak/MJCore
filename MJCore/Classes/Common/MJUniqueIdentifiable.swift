//
//  MJUniqueIdentifiable.swift
//  MJCore
//
//  Created by Martin Janák on 28/10/2018.
//

import Foundation

public protocol MJUniqueIdentifiable {
    var uniqueId: String { get }
}

extension MJUniqueIdentifiable {
    
    public var uniqueIdType: String {
        return "\(Self.self)-" + uniqueId
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uniqueIdType == rhs.uniqueIdType
    }
    
    public static func != (lhs: Self, rhs: Self) -> Bool {
        return !(lhs == rhs)
    }
    
}
