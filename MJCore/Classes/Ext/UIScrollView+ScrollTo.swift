//
//  UIScrollView+ScrollTo.swift
//  MJCore
//
//  Created by Martin Janák on 16/07/2018.
//

import UIKit

extension UIScrollView {
    
    public func scrollTo(view: UIView, offset: CGFloat, animated: Bool = true) {
        guard let origin = view.superview else {
            return
        }
        let childStartPoint = origin.convert(view.frame.origin, to: self)
        self.scrollRectToVisible(
            CGRect(
                x: 0,
                y: childStartPoint.y - offset,
                width: 1,
                height: self.frame.height
            ),
            animated: animated
        )
    }
    
    public func scrollToTop(animated: Bool = true) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
    
    public func scrollToBottom(animated: Bool = true) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if bottomOffset.y > 0 {
            setContentOffset(bottomOffset, animated: animated)
        }
    }
}
