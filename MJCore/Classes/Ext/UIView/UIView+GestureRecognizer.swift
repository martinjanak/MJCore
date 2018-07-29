//
//  UIView+EndEditing.swift
//  MJCore
//
//  Created by Martin Janák on 16/07/2018.
//

import Foundation

extension UIView {
    
    public func removeGestureRecognizers() {
        if let gestureRecognizers = gestureRecognizers, gestureRecognizers.count > 0 {
            for gr in gestureRecognizers {
                removeGestureRecognizer(gr)
            }
        }
    }
    
}
