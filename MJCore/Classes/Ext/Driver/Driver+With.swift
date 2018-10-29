//
//  Driver+With.swift
//  MJCore
//
//  Created by Martin Janák on 29/10/2018.
//

import RxSwift
import RxCocoa

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {
    
    public func with<WithElement>(
        _ observable: Driver<WithElement>
    ) -> Driver<(E, WithElement)> {
        return self.withLatestFrom(observable) { ($0, $1) }
    }
    
    public func with<A, B>(
        _ tuple: (Driver<A>, Driver<B>)
    ) -> Driver<(E, A, B)> {
        return self
            .withLatestFrom(tuple.0) { ($0, $1) }
            .withLatestFrom(tuple.1) { ($0.0, $0.1, $1) }
    }
    
    public func with<A, B, C>(
        _ tuple: (Driver<A>, Driver<B>, Driver<C>)
    ) -> Driver<(E, A, B, C)> {
        return self
            .withLatestFrom(tuple.0) { ($0, $1) }
            .withLatestFrom(tuple.1) { ($0.0, $0.1, $1) }
            .withLatestFrom(tuple.2) { ($0.0, $0.1, $0.2, $1) }
    }
    
    public func with<A, B, C, D>(
        _ tuple: (Driver<A>, Driver<B>, Driver<C>, Driver<D>)
    ) -> Driver<(E, A, B, C, D)> {
        return self
            .withLatestFrom(tuple.0) { ($0, $1) }
            .withLatestFrom(tuple.1) { ($0.0, $0.1, $1) }
            .withLatestFrom(tuple.2) { ($0.0, $0.1, $0.2, $1) }
            .withLatestFrom(tuple.3) { ($0.0, $0.1, $0.2, $0.3, $1) }
    }
    
}
