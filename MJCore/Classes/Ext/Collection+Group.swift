//
//  Collection+Group.swift
//  MJCore
//
//  Created by Martin Janák on 24/07/2018.
//

import Foundation

extension Sequence {
    
    func group<GroupingType: Hashable>(
        by key: (Iterator.Element) -> GroupingType
    ) -> [GroupingType: [Iterator.Element]] {
        var groups = [GroupingType: [Iterator.Element]]()
        forEach { element in
            let key = key(element)
            if case nil = groups[key]?.append(element) {
                groups[key] = [element]
            }
        }
        return groups
    }
    
}
