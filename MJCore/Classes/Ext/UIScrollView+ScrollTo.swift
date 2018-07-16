//
//  UIScrollView+ScrollTo.swift
//  MJCore
//
//  Created by Martin Janák on 16/07/2018.
//

import UIKit

extension UIScrollView {
    
    func scrollTo(view: UIView, animated: Bool) {
        if let origin = view.superview {
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            self.scrollRectToVisible(
                CGRect(
                    x:0,
                    y: childStartPoint.y,
                    width: 1,
                    height: self.frame.height
                ),
                animated: animated
            )
        }
    }
    
    func scrollToTop(animated: Bool) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
    
    func scrollToBottom(animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if bottomOffset.y > 0 {
            setContentOffset(bottomOffset, animated: animated)
        }
    }
}
