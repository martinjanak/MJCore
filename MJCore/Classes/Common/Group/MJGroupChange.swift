//
//  MJGroupChange.swift
//  MJCore
//
//  Created by Martin Janák on 30/10/2018.
//

import Foundation

public enum MJGroupChange<Element: MJGroupElementType> {
    case initialization(elements: [Element])
    case cyclicPermutation(index: Int, count: Int)
    case model(operations: MJGroupModelOperations<Element>)
}

public struct MJGroupModelOperations<Element: MJGroupElementType> {
    
    public var inserts: [MJGroupElementOperation<Element>]
    public var deletes: [MJGroupElementOperation<Element>]
    public var updates: [MJGroupElementOperation<Element>]
    
    public var hasAny: Bool {
        return inserts.count + deletes.count + updates.count > 0
    }
    
}

public struct MJGroupElementOperation<Model: MJGroupElementType> {
    public var model: Model
    public var index: Int
}

extension MJGroupModelOperations {
    public static func +(
        left: MJGroupModelOperations<Element>,
        right: MJGroupModelOperations<Element>
    ) -> MJGroupModelOperations<Element> {
        return MJGroupModelOperations<Element>(
            inserts: left.inserts + right.inserts,
            deletes: left.deletes + right.deletes,
            updates: left.updates + right.updates
        )
    }
}
