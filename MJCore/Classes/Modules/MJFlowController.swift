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
        navBarHidden: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        guard let navigation = navigation else {
            return
        }
        if navigation.presentedViewController != nil {
            navigation.dismiss(animated: animated, completion: completion)
        } else {
            if navigation.isNavigationBarHidden != navBarHidden {
                navigation.setNavigationBarHidden(navBarHidden, animated: animated)
            }
            navigation.popViewController(animated: animated)
        }
    }
    
    public func backToRoot(
        animated: Bool = true,
        navBarHidden: Bool = false
    ) {
        guard let navigation = navigation else {
            return
        }
        if navigation.presentedViewController != nil {
            navigation.dismiss(animated: animated) {
                if navigation.isNavigationBarHidden != navBarHidden {
                    navigation.setNavigationBarHidden(navBarHidden, animated: animated)
                }
                navigation.popToRootViewController(animated: animated)
            }
        } else {
            if navigation.isNavigationBarHidden != navBarHidden {
                navigation.setNavigationBarHidden(navBarHidden, animated: animated)
            }
            navigation.popToRootViewController(animated: animated)
        }
    }
    
    public func enroot(
        _ controller: UIViewController,
        navBarHidden: Bool = false,
        direction: UINavigationController.Direction? = nil
    ) {
        navigation?.setNavigationBarHidden(navBarHidden, animated: false)
        navigation?.set(rootViewController: controller, direction: direction)
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
