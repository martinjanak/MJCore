//
//  MJSideScrollView.swift
//  MJCore
//
//  Created by Martin Janák on 03/07/2018.
//

import UIKit

open class MJHorizontalScrollView: MJView {
    
    open func setup(_ pageView: UIView) {
        // to be overriden
        fatalError("Subclasses need to implement the `addPageView()` method.")
    }
    
}
