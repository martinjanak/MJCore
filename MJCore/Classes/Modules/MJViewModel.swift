//
//  MJViewModel.swift
//  MJCore
//
//  Created by Martin Janák on 08/07/2018.
//

import RxSwift
import RxCocoa

open class MJViewModel {
    
    public let errorMessage = BehaviorRelay<String?>(value: nil)
    public let infoMessage = BehaviorRelay<String?>(value: nil)
    public let isLoading = BehaviorRelay<Bool>(value: false)
    
    required public init() { }
    
    open func initBindings() {
        // override
    }
    
}
