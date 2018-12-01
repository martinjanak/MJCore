//
//  MJPageViewModel.swift
//  MJCore
//
//  Created by Martin Janák on 01/08/2018.
//

import RxSwift
import RxCocoa

open class MJPageViewModel<PagingModel: MJPagingModelType>: MJViewModel {
    
    public let pagingModel = BehaviorRelay<PagingModel?>(value: nil)
    
    public var key: String? {
        return pagingModel.value?.key
    }
    
    public var uniqueId: String? {
        return pagingModel.value?.uniqueId
    }
    
    open func initBindings() { }
    
}
