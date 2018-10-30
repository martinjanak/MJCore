//
//  MJFixedOrderGroupChange.swift
//  MJCore
//
//  Created by Martin Janák on 30/10/2018.
//

import Foundation

public enum MJFixedOrderGroupChange<Element: MJGroupElementType> {
    case initialization(elements: [Element])
    case model(operations: MJFixedOrderGroupModelOperations<Element>)
}

public struct MJFixedOrderGroupModelOperations<Element: MJGroupElementType> {
    
    public var deletes: [String]
    public var appends: [Element]
    public var updates: [String: Element]
    
    public var hasAny: Bool {
        return deletes.count + appends.count > 0
    }
    
}
