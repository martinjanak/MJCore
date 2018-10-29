//
//  Array+Permutation.swift
//  MJCore
//
//  Created by Martin Janák on 29/10/2018.
//

import Foundation

extension Array where Element: MJGroupElementType {

    public func getTranspositions(of array: [Element]) -> [(from: Int, to: Int)]? {
        guard self.count > 1, self.count == array.count else { return nil }
        var map = [String: Int]()
        for (index, element) in self.enumerated() {
            map[element.totalId] = index
        }
        var transpositions = [(from: Int, to: Int)]()
        for (to, otherElement) in array.enumerated() {
            if let from = map[otherElement.totalId] {
                if to != from {
                    transpositions.append((from: from, to: to))
                }
            } else {
                return nil
            }
        }
        return transpositions
    }
    
    public func getCylicPermutationIndex(of array: [Element]) -> Int? {
        guard self.count > 1, self.count == array.count else { return nil }
        let testArray: [Element] = self + self
        let indexOptional = testArray.firstIndex { element in
            return element.uniqueIdType == array[0].uniqueIdType
                && element.updateSignature == array[0].updateSignature
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

public struct MJTransposition {
    let from: Int
    let to: Int
}
