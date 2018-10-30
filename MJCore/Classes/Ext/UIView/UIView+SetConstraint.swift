//
//  UIView.swift
//  MJCore
//
//  Created by Martin Janák on 30/10/2018.
//

import UIKit
import Stevia

extension UIView {
    
    @discardableResult
    public func setTop(_ constant: CGFloat) -> UIView {
        if let topConstraint = self.topConstraint {
            topConstraint.constant = constant
            return self
        } else {
            return top(constant)
        }
    }
    
    @discardableResult
    public func setBottom(_ constant: CGFloat) -> UIView {
        if let bottomConstraint = self.bottomConstraint {
            bottomConstraint.constant = constant
            return self
        } else {
            return bottom(constant)
        }
    }
    
    @discardableResult
    public func setLeft(_ constant: CGFloat) -> UIView {
        if let leftConstraint = self.leftConstraint {
            leftConstraint.constant = constant
            return self
        } else {
            return left(constant)
        }
    }
    
    @discardableResult
    public func setRight(_ constant: CGFloat) -> UIView {
        if let rightConstraint = self.rightConstraint {
            rightConstraint.constant = constant
            return self
        } else {
            return right(constant)
        }
    }
    
    @discardableResult
    public func setHeight(_ constant: CGFloat) -> UIView {
        if let heightConstraint = self.heightConstraint {
            heightConstraint.constant = constant
            return self
        } else {
            return height(constant)
        }
    }
    
    @discardableResult
    public func setWidth(_ constant: CGFloat) -> UIView {
        if let widthConstraint = self.widthConstraint {
            widthConstraint.constant = constant
            return self
        } else {
            return width(constant)
        }
    }
    
}
