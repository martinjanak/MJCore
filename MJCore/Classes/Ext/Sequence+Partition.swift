//
//  Collection+Group.swift
//  MJCore
//
//  Created by Martin Janák on 24/07/2018.
//

import Foundation

extension Sequence {
    
    func partition<PartitioningType: Hashable>(
        by key: (Iterator.Element) -> PartitioningType
    ) -> [PartitioningType: [Iterator.Element]] {
        var partitions = [PartitioningType: [Iterator.Element]]()
        forEach { element in
            let key = key(element)
            if case nil = partitions[key]?.append(element) {
                partitions[key] = [element]
            }
        }
        return partitions
    }
    
}
