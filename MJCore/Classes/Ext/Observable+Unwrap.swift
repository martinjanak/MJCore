//
//  Observable+Unwrap.swift
//  MJCore
//
//  Created by Martin Janák on 10/07/2018.
//

import RxSwift

extension Observable {
    
    public func unwrap<V>() -> Observable<V> where Element == V? {
        return self
            .filter { $0 != nil }
            .map { $0! }
    }
    
}
