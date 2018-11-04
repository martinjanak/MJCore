//
//  MJBaseViewComponent.swift
//  MJCore
//
//  Created by Martin Janák on 04/11/2018.
//

import UIKit

open class MJBaseViewComponent: MJView {
    
    required public init() {
        super.init(frame: .zero)
        initView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
