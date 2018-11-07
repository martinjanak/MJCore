//
//  Driver+Drive.swift
//  MJCore
//
//  Created by Martin Janák on 07/11/2018.
//

import RxSwift
import RxCocoa

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {
    
    public func drive(_ onNext: @escaping (E) -> Void) -> Disposable {
        return self
            .drive(onNext: onNext)
    }
    
}
