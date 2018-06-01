//
//  MJFlowController.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import UIKit
import RxSwift

open class MJFlowController<Service> {
    
    private weak var navigation: UINavigationController?
    public let service: Service
    
    private weak var parentFlowController: MJFlowController<Service>?
    private var childFlowController: MJFlowController<Service>?
    
    public var currentViewController: UIViewController? {
        return navigation?.viewControllers.last
    }
    
    public init(service: Service) {
        self.service = service
    }
    
    open func start(navigation: UINavigationController) {
        self.navigation = navigation
        // override and present/push/root view controller
    }
    
    public func startParentFlow() {
        guard let navigation = navigation else {
            return
        }
        parentFlowController?.start(navigation: navigation)
    }
    
    public func start(_ flowController: MJFlowController<Service>) {
        guard let navigation = navigation else {
            return
        }
        childFlowController = flowController
        flowController.parentFlowController = self
        flowController.start(navigation: navigation)
    }
    
    public func back(
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let navigation = navigation else {
            return
        }
        if navigation.presentedViewController != nil {
            navigation.dismiss(animated: animated, completion: completion)
        } else {
            navigation.popViewController(animated: animated)
        }
    }
    
    public func enroot(
        _ controller: UIViewController,
        direction: UINavigationController.Direction? = nil,
        navBarHidden: Bool = false
    ) {
        navigation?.setNavigationBarHidden(navBarHidden, animated: direction != nil)
        navigation?.set(root: controller, direction: direction)
    }
    
    public func push(_ controller: UIViewController, animated: Bool = true, navBarHidden: Bool = false) {
        if navigation?.isNavigationBarHidden != navBarHidden {
            navigation?.setNavigationBarHidden(navBarHidden, animated: animated)
        }
        navigation?.pushViewController(controller, animated: animated)
    }
    
    public func present(
        _ controller: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let navigation = navigation else {
            return
        }
        if navigation.presentedViewController != nil {
            navigation.dismiss(animated: animated) {
                navigation.present(controller, animated: animated, completion: completion)
            }
        } else {
            navigation.present(controller, animated: animated, completion: completion)
        }
    }
    
    public func presentModal(
        _ controller: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        
        present(controller, animated: animated, completion: completion)
    }
}
