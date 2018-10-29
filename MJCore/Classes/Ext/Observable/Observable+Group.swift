//
//  Observable+Group.swift
//  MJCore
//
//  Created by Martin Janák on 29/10/2018.
//

import RxSwift

extension Observable {
    
    public func bind<E>(to group: MJGroup<E>) -> Disposable where Element == [E] {
        return self
            .bind(onNext: { [weak group] elements in
                group?.update(elements)
            })
    }
    
}
