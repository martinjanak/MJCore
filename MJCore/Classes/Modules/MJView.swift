//
//  MJView.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import UIKit
import Stevia

open class MJView: UIView {
    
    private let endEditingTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(endEditing)
    )
    
    open func setup() {
        fatalError("setup() has not been implemented")
    }
    
    public var endsEditingOnTap: Bool = false {
        didSet {
            if endsEditingOnTap {
                addGestureRecognizer(
                    endEditingTapGestureRecognizer
                )
            } else {
                removeGestureRecognizer(
                    endEditingTapGestureRecognizer
                )
            }
        }
    }
    
}
