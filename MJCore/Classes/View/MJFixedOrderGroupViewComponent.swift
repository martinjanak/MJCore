//
//  MJGroupViewComponent.swift
//  MJCore
//
//  Created by Martin Janák on 05/12/2018.
//

import RxSwift

open class MJFixedOrderGroupViewComponent<Model: MJGroupElementType, ViewModel>
    : MJSmartViewComponent<ViewModel> {
    
    public let disposeBag = DisposeBag()
    
    public let group: MJFixedOrderGroup<Model>
    
    required public init() {
        group = MJFixedOrderGroup<Model>()
        super.init()
        bindGroup(change: group.change)
    }
    
    open func bindGroup(change: Observable<MJFixedOrderGroupChange<Model>>) {
        fatalError("bindGroup(change:) has not been implemented")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
