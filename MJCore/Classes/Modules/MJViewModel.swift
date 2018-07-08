//
//  MJViewModel.swift
//  MJCore
//
//  Created by Martin Janák on 08/07/2018.
//

import RxSwift

open class MJViewModel {
    
    let errorMessage = Variable<String?>(nil)
    let isLoading = Variable<Bool>(false)
    
    required public init() { }
    
}
