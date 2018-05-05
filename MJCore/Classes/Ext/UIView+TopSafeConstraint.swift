//
//  UIView+TopSafeConstraint.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import UIKit

extension UIView {
    
    @discardableResult
    public func topSafe(_ constant: CGFloat = 0) -> UIView {
        if let spv = superview {
            self.topAnchor
                .constraint(equalTo: spv.safeAreaLayoutGuide.topAnchor, constant: constant)
                .isActive = true
        }
        return self
    }
    
}
