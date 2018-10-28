//
//  Observable+FilterOne.swift
//  MJCore
//
//  Created by Martin Janák on 26/10/2018.
//

import RxSwift

extension Observable {
    
    public func findOne<V>(_ that: @escaping ((V) -> Bool)) -> Observable<V?> where Element == [V] {
        return self
            .map { values in
                let filtered = values.filter { that($0) }
                if filtered.count > 0 {
                    return filtered[0]
                } else {
                    return nil
                }
            }
    }
    
}
