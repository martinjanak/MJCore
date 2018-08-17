//
//  Observable+Cast.swift
//  MJCore
//
//  Created by Martin Janák on 16/08/2018.
//

import RxSwift

extension Observable {
    
    public func cast<Input, Output>(_ valueType: Output.Type) -> Observable<Output> where Element == Input?  {
        return self
            .filter { $0 != nil && $0 is Output }
            .map { $0 as! Output }
    }
    
    public func cast<Output>(_ valueType: Output.Type) -> Observable<Output>  {
        return self
            .filter { $0 is Output }
            .map { $0 as! Output }
    }
    
}
