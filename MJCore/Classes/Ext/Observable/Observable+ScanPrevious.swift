//
//  Observable+ScanPrevious.swift
//  MJCore
//
//  Created by Martin Janák on 19/10/2018.
//

import RxSwift

extension Observable {
    
    public func scanPrevious() -> Observable<PreviousScanner<Element>> {
        return self.scan(PreviousScanner<Element>(previous: nil, current: nil)) { previous, current in
            return PreviousScanner<Element>(previous: previous.current, current: current)
        }
    }
    
}

public struct PreviousScanner<Value> {
    public let previous: Value?
    public let current: Value?
}
