//
//  Array+TableChange.swift
//  MJCore
//
//  Created by Martin Janák on 05/08/2018.
//

import Foundation

// https://en.wikipedia.org/wiki/Longest_common_subsequence_problem
extension Array where Element: Equatable {
    
    public func tableChange(with second: Array<Element>) -> MJTableChange<Element> {
        let lcs = self.lcs(with: second)
        return diff(lcs: lcs, with: second, i: self.count, j: second.count)
    }
    
    private func diff(lcs C: [[Int]], with second: Array<Element>, i: Int, j: Int) -> MJTableChange<Element> {
        let first = self
        var diff = MJTableChange<Element>(
            inserts: [MJTableRowChange<Element>](),
            deletes: [MJTableRowChange<Element>](),
            updates: [MJTableRowChange<Element>]()
        )
        if i > 0, j > 0, first[i-1] == second[j-1] {
            diff.updates.append(MJTableRowChange<Element>(model: second[j-1], index: j-1))
            diff = diff + self.diff(lcs: C, with: second, i: i-1, j: j-1)
            return diff
        } else if j > 0, (i == 0 || C[i][j-1] >= C[i-1][j]) {
            diff.inserts.append(MJTableRowChange<Element>(model: second[j-1], index: j-1))
            diff = diff + self.diff(lcs: C, with: second, i: i, j: j-1)
            return diff
        } else if i > 0, (j == 0 || C[i][j-1] < C[i-1][j]) {
            diff.deletes.append(MJTableRowChange<Element>(model: first[i-1], index: i-1))
            diff = diff + self.diff(lcs: C, with: second, i: i-1, j: j)
            return diff
        } else {
            return MJTableChange<Element>(
                inserts: [MJTableRowChange<Element>](),
                deletes: [MJTableRowChange<Element>](),
                updates: [MJTableRowChange<Element>]()
            )
        }
    }
    
    public func lcs(with second: Array<Element>) -> [[Int]] {
        let first = self
        var C = [[Int]](repeating: [Int](repeating: 0, count: second.count + 1), count: first.count + 1)
        for i in 1...first.count {
            for j in 1...second.count {
                if first[i-1] == second[j-1] {
                    C[i][j] = C[i-1][j-1] + 1
                } else {
                    C[i][j] = Swift.max(C[i][j-1], C[i-1][j])
                }
            }
        }
        return C
    }
    
}

public struct MJTableRowChange<Model> {
    public var model: Model
    public var index: Int
}

public struct MJTableChange<E> {
    public var inserts: [MJTableRowChange<E>]
    public var deletes: [MJTableRowChange<E>]
    public var updates: [MJTableRowChange<E>]
}

extension MJTableChange where E: Equatable {
    
    public static func +(left: MJTableChange<E>, right: MJTableChange<E>) -> MJTableChange<E> {
        return MJTableChange<E>(
            inserts: left.inserts + right.inserts,
            deletes: left.deletes + right.deletes,
            updates: left.updates + right.updates
        )
    }
    
}
