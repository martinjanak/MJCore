//
//  MJViewComponent.swift
//  MJCore
//
//  Created by Martin Janák on 12/06/2018.
//

import UIKit
import Stevia

open class MJViewComponent: MJView {
    
    public init() {
        super.init(frame: .zero)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
