//
//  UINavigationController+Root.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import UIKit

extension UINavigationController {
    
    public enum Direction {
        case push
        case pop
    }
    
    public func set(rootViewController: UIViewController, direction: Direction? = nil) {
        if let direction = direction {
            addTransition(direction)
        }
        viewControllers.removeAll()
        pushViewController(rootViewController, animated: false)
        popToRootViewController(animated: false)
    }
    
    private func addTransition(_ direction: Direction) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(
            name: kCAMediaTimingFunctionEaseInEaseOut
        )
        transition.type = kCATransitionPush
        switch direction {
        case .push:
            transition.subtype = kCATransitionFromRight
        case .pop:
            transition.subtype = kCATransitionFromLeft
        }
        view.layer.add(transition, forKey: nil)
    }
}
