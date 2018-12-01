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
    ViewModel: MJPageViewModel<PagingModel>
>
    : MJViewController<View, ViewModel>, MJPagingViewControllerType {
    
    required public init(viewModel: ViewModel, pagingModel: PagingModel) {
        super.init(viewModel: viewModel)
        viewModel.pagingModel.accept(pagingModel)
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
