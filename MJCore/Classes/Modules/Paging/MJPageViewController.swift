//
//  MJPageViewController.swift
//  MJCore
//
//  Created by Martin Janák on 01/08/2018.
//

import Foundation

open class MJPageViewController<
    PagingModel: MJPagingModelType,
    View: MJView,
    Model: MJPageViewModel<PagingModel>
>
    : MJViewController<View, Model>, MJPagingViewControllerType {
    
    required public init(_ pagingModel: PagingModel) {
        super.init()
        viewModel.pagingModel.value = pagingModel
    }
    
    open var uniqueId: String {
        return viewModel.pagingModel.value?.uniqueId ?? ""
    }
    
    open class func getKey() -> String {
        fatalError("getKey() has not been implemented")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
