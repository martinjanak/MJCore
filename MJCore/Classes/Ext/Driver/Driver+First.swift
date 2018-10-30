//
//  Driver+FindOne.swift
//  MJCore
//
//  Created by Martin Janák on 26/10/2018.
//

import RxSwift
import RxCocoa

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {
    
    public func first<V>(where condition: @escaping ((V) -> Bool)) -> Driver<V?> where E == [V] {
        return self
            .map { $0.first(where: condition) }
    }
    
}
