//
//  Observable+AsDriverIgnoringErrors.swift
//  MJCore
//
//  Created by Martin Janák on 07/11/2018.
//

import RxSwift
import RxCocoa

extension Observable {
    
    func asDriverIgnoringErrors() -> Driver<Element> {
        return self
            .map { $0 as Element? }
            .asDriver(onErrorJustReturn: nil)
            .unwrap()
    }
    
}
