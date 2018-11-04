//
//  MJSmartViewComponent.swift
//  MJCore
//
//  Created by Martin Janák on 04/11/2018.
//

import UIKit
import RxSwift

open class MJSmartViewComponent<ViewModel: MJViewModel>: MJView {
    
    public let viewModel = ViewModel()
    
    required public init() {
        super.init(frame: .zero)
        initView()
    }
    
    open func initBindings() {
        // optional override
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
