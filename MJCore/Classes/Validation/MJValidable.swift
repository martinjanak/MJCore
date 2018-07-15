//
//  MJValidator.swift
//  MJCore
//
//  Created by Martin Janák on 14/07/2018.
//

import RxSwift

public protocol MJValidable {
    var isValid: Variable<Bool> { get }
    var isDirty: Variable<Bool> { get }
}

extension MJValidable {
    
    public static func all(_ validables: [MJValidable]) -> Observable<Bool> {
        let observables = validables.map { $0.isValid.asObservable() }
        return Observable.combineLatest(observables)
            .map { $0.reduce(true, { $0 && $1 }) }
    }
    
}
