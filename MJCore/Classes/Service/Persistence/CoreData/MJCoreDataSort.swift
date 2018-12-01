//
//  MJCoreDataSort.swift
//  MJCore
//
//  Created by Martin Janák on 16/06/2018.
//

import CoreData

public enum MJCoreDataSort {
    
    case ascending(String)
    case descending(String)
    case multiple([NSSortDescriptor])
    
    var descriptors: [NSSortDescriptor] {
        switch self {
        case .ascending(let key):
            return [NSSortDescriptor(key: key, ascending: true)]
        case .descending(let key):
            return [NSSortDescriptor(key: key, ascending: false)]
        case .multiple(let descriptors):
            return descriptors
        }
    }
    
}

extension MJCoreDataSort {
    
    public static func &&(left: MJCoreDataSort, right: MJCoreDataSort) -> MJCoreDataSort {
        let descriptors = left.descriptors + right.descriptors
        return .multiple(descriptors)
    }
    
}
