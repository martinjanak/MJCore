//
//  Array+TableChange.swift
//  MJCore
//
//  Created by Martin Janák on 05/08/2018.
//

import Foundation

// https://en.wikipedia.org/wiki/Longest_common_subsequence_problem
extension Array where Element: MJGroupElementType {
    
    public func lcsOperations(with second: Array<Element>) -> MJGroupModelOperations<Element> {
        let lcs = self.lcs(with: second)
        var diff = self.diff(lcs: lcs, with: second, i: self.count, j: second.count)
        diff.inserts.reverse()
        return diff
    }
    
    public func fixedOrderLcsOperations(with second: Array<Element>) -> MJFixedOrderGroupModelOperations<Element> {
        let lcs = self.lcs(with: second)
        var diff = self.diff(lcs: lcs, with: second, i: self.count, j: second.count)
        diff.inserts.sort { $0.index < $1.index }
        
        var updates = [String: Element]()
        for update in diff.updates {
            updates[update.model.uniqueIdType] = update.model
        }
        
        return MJFixedOrderGroupModelOperations<Element>(
            deletes: diff.deletes.map { $0.model.uniqueIdType },
            appends: diff.inserts.map { $0.model },
            updates: updates
        )
    }
    
    private func diff(lcs C: [[Int]], with second: Array<Element>, i: Int, j: Int) -> MJGroupModelOperations<Element> {
        let first = self
        var diff = MJGroupModelOperations<Element>(
            inserts: [MJGroupElementOperation<Element>](),
            deletes: [MJGroupElementOperation<Element>](),
            updates: [MJGroupElementOperation<Element>]()
        )
        if i > 0, j > 0, first[i-1] == second[j-1] {
            if first[i-1] !~ second[j-1] {
                diff.updates.append(MJGroupElementOperation<Element>(model: second[j-1], index: i-1))
            }
            diff = diff + self.diff(lcs: C, with: second, i: i-1, j: j-1)
            return diff
        } else if j > 0, (i == 0 || C[i][j-1] >= C[i-1][j]) {
            diff.inserts.append(MJGroupElementOperation<Element>(model: second[j-1], index: j-1))
            diff = diff + self.diff(lcs: C, with: second, i: i, j: j-1)
            return diff
        } else if i > 0, (j == 0 || C[i][j-1] < C[i-1][j]) {
            diff.deletes.append(MJGroupElementOperation<Element>(model: first[i-1], index: i-1))
            diff = diff + self.diff(lcs: C, with: second, i: i-1, j: j)
            return diff
        } else {
            return MJGroupModelOperations<Element>(
                inserts: [MJGroupElementOperation<Element>](),
                deletes: [MJGroupElementOperation<Element>](),
                updates: [MJGroupElementOperation<Element>]()
            )
        }
    }
    
    private func lcs(with second: Array<Element>) -> [[Int]] {
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
