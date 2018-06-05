//
//  Observable+None.swift
//  MJCore
//
//  Created by Martin Janák on 30/05/2018.
//

import RxSwift

public enum MJObservableError: Error {
    case none
    case batch(message: String)
}

extension Observable {

    public static func none<V>() -> Observable<MJResult<V>> where Element == MJResult<V> {
        return .just(.failure(error: MJObservableError.none))
    }
    
}

extension Observable where Element == MJResultSimple {
    
    public static func none() -> Observable<MJResultSimple> {
        return .just(.failure(error: MJObservableError.none))
    }
    
}
