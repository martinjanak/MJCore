//
//  MJViewModel.swift
//  MJCore
//
//  Created by Martin Janák on 08/07/2018.
//

import RxSwift

open class MJViewModel {
    
    public let errorMessage = Variable<String?>(nil)
    public let infoMessage = Variable<String?>(nil)
    public let isLoading = Variable<Bool>(false)
    
    required public init() { }
    
    open func initBindings() {
        // override
    }
    
}
