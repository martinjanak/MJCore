//
//  Observable+FilterOne.swift
//  MJCore
//
//  Created by Martin Janák on 26/10/2018.
//

import RxSwift

extension Observable {
    
    public func first<V>(where condition: @escaping ((V) -> Bool)) -> Observable<V?> where Element == [V] {
        return self
            .map { $0.first(where: condition) }
    }
    
}
