//
//  MJPagingScrollVM.swift
//  MJCore
//
//  Created by Martin Janák on 01/08/2018.
//

import Foundation

open class MJPagingScrollVM<PagingModel: MJPagingModelType>: MJViewModel {
    
    public internal(set) var pagingVM: MJPagingViewModel<PagingModel>!
    
    open func initBindings() { }
    
}
