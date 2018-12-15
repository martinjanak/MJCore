//
//  UIStackView+Ext.swift
//  MJCore
//
//  Created by Martin Janák on 26/07/2018.
//

import UIKit

extension UIStackView {
    
    @discardableResult
    public func addArranged(_ arrangedSubviews: UIView...) -> UIStackView {
        arrangedSubviews.forEach(addArrangedSubview)
        return self
    }
    
    @discardableResult
    public func addArranged(_ arrangedSubviews: [UIView]) -> UIStackView {
        arrangedSubviews.forEach(addArrangedSubview)
        return self
    }
    
    public func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { subview in
            removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
}
