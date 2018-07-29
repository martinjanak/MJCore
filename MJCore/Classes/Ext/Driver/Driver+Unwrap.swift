//
//  Driver+Unwrap.swift
//  MJCore
//
//  Created by Martin Janák on 28/07/2018.
//

import RxSwift
import RxCocoa

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {
    
    public func unwrap<Value>() -> Driver<Value> where E == Value? {
        return self
            .filter { $0 != nil }
            .map { $0! }
    }
    
}
