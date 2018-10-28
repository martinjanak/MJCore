//
//  MJGroup.swift
//  MJCore
//
//  Created by Martin Janák on 28/10/2018.
//

import Foundation

public typealias MJGroupElementType = MJUniqueIdentifiable & MJUpdatable

public struct MJGroupElementChange<Model: MJGroupElementType> {
    public var model: Model
    public var index: Int
}

public struct MJGroupChange<Element: MJGroupElementType> {
    
    public var inserts: [MJGroupElementChange<Element>]
    public var deletes: [MJGroupElementChange<Element>]
    public var updates: [MJGroupElementChange<Element>]
    
    public var hasAny: Bool {
        return inserts.count + deletes.count + updates.count > 0
    }
    
}

extension MJGroupChange {
    public static func +(left: MJGroupChange<Element>, right: MJGroupChange<Element>) -> MJGroupChange<Element> {
        return MJGroupChange<Element>(
            inserts: left.inserts + right.inserts,
            deletes: left.deletes + right.deletes,
            updates: left.updates + right.updates
        )
    }
}
