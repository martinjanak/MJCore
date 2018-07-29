//
//  Observable+Empty.swift
//  MJCore
//
//  Created by Martin Janák on 07/06/2018.
//

import RxSwift

extension Observable {
    
    public func bindEmpty() -> Disposable {
        return self.bind(onNext: { _ in })
    }
    
}
