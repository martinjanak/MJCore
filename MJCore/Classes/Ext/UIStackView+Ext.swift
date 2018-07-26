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
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        NSLayoutConstraint.deactivate(removedSubviews.flatMap { $0.constraints })
        removedSubviews.forEach { $0.removeFromSuperview() }
    }
}
