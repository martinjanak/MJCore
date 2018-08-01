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
        model.pagingModel.value = pagingModel
    }
    
    open var uniqueId: String {
        return model.pagingModel.value?.uniqueId ?? ""
    }
    
    open static var key: String {
        // override!
        return ""
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
