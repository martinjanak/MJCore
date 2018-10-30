//
//  Observable+BindToGroup.swift
//  MJCore
//
//  Created by Martin Janák on 30/10/2018.
//

import RxSwift

extension Observable {
    
    public func bind<GroupElement: MJGroupElementType>(
        toGroup: MJGroup<GroupElement>
    ) -> Disposable where Element == [GroupElement] {
        return self
            .bind(onNext: { [weak toGroup] elements in
                toGroup?.update(elements)
            })
    }
    
    public func bind<GroupElement: MJGroupElementType>(
        toGroup: MJFixedOrderGroup<GroupElement>
    ) -> Disposable where Element == [GroupElement] {
        return self
            .bind(onNext: { [weak toGroup] elements in
                toGroup?.update(elements)
            })
    }
    
}
