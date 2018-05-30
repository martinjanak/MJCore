//
//  Observable+None.swift
//  MJCore
//
//  Created by Martin Janák on 30/05/2018.
//

import RxSwift

public enum ObservableError: Error {
    case none
}

extension Observable {

    public static func none<V>() -> Observable<MJResult<V>> where Element == MJResult<V> {
        return Observable<MJResult<V>>.just(
            MJResult<V>.failure(error: ObservableError.none)
        )
    }
    
}

extension Observable where Element == MJResultSimple {
    
    public static func none() -> Observable<MJResultSimple> {
        return Observable<MJResultSimple>.just(
            MJResultSimple.failure(error: ObservableError.none)
        )
    }
    
}
