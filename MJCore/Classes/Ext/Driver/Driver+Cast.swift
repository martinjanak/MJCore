//
//  Driver+Cast.swift
//  MJCore
//
//  Created by Martin Janák on 16/08/2018.
//

import RxSwift
import RxCocoa

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {
    
    public func cast<Input, Output>(_ valueType: Output.Type) -> Driver<Output> where E == Input?  {
        return self
            .filter { $0 != nil && $0 is Output }
            .map { $0 as! Output }
    }
    
    public func cast<Output>(_ valueType: Output.Type) -> Driver<Output>  {
        return self
            .filter { $0 is Output }
            .map { $0 as! Output }
    }
    
}
