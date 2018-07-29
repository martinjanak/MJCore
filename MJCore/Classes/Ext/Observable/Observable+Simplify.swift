//
//  Observable+Simplify.swift
//  MJCore
//
//  Created by Martin Janák on 21/05/2018.
//

import RxSwift

extension Observable {
    
    public func simplify<V>() -> Observable<MJResultSimple> where Element == MJResult<V> {
        return self.map({ $0.simplify() })
    }
    
}
