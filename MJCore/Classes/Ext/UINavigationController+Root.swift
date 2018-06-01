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
    
    public func set(root: UIViewController, direction: Direction? = nil) {
        if let direction = direction {
            switch direction {
            case .pop:
                viewControllers.insert(root, at: 0)
                popToRootViewController(animated: true)
            case .push:
                setViewControllers([root], animated: true)
            }
        } else {
            if viewControllers.count > 0 {
                viewControllers.insert(root, at: 0)
                popToRootViewController(animated: false)
            } else {
                pushViewController(root, animated: false)
            }
        }
    }
}
