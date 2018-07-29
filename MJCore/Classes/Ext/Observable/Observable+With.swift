//
//  Observable+With.swift
//  MJCore
//
//  Created by Martin Janák on 23/07/2018.
//

import RxSwift

extension Observable {
    
    public func with<WithElement>(
        _ observable: Observable<WithElement>
    ) -> Observable<(Element, WithElement)> {
        return self.withLatestFrom(observable) { ($0, $1) }
    }
    
}
