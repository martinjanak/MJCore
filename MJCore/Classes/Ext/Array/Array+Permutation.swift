//
//  Array+Permutation.swift
//  MJCore
//
//  Created by Martin Janák on 29/10/2018.
//

import Foundation

extension Array where Element: MJGroupElementType {
    
    public func getCylicPermutationIndex(of array: [Element]) -> Int? {
        guard self.count > 1, self.count == array.count else { return nil }
        let testArray: [Element] = self + self
        let indexOptional = testArray.firstIndex { element in
            return element.totalId == array[0].totalId
        }
        guard let index = indexOptional else { return nil }
        for i in 0...self.count-1 {
            if testArray[index + i].totalId != array[i].totalId {
                return nil
            }
        }
        return index
    }
    
}
