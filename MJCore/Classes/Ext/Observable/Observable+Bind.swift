//
//  Observable+Bind.swift
//  MJCore
//
//  Created by Martin Janák on 07/11/2018.
//

import RxSwift

extension Observable {
    
    public func bind(_ onNext: @escaping (Element) -> Void) -> Disposable {
        return self
            .bind(onNext: onNext)
    }
    
}
