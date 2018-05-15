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
    
    public weak var parentFlowController: MJFlowController<Service>?
    public var childFlowController: MJFlowController<Service>?
    
    public init(service: Service) {
        self.service = service
    }
    
    open func start(navigation: UINavigationController) {
        self.navigation = navigation
        // override and present/push/root view controller
    }
    
    public func start(_ flowController: MJFlowController<Service>) {
        guard let navigation = navigation else {
            return
        }
        childFlowController = flowController
        flowController.parentFlowController = self
        flowController.start(navigation: navigation)
    }
    
    public func back(animated: Bool = true) {
        guard let navigation = navigation else {
            return
        }
        if navigation.presentedViewController != nil {
            navigation.dismiss(animated: animated, completion: nil)
        } else {
            navigation.popViewController(animated: animated)
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
    
    public func push(_ controller: UIViewController, animated: Bool = true) {
        navigation?.pushViewController(controller, animated: animated)
    }
    
    public func present(_ controller: UIViewController, animated: Bool = true) {
        guard let navigation = navigation else {
            return
        }
        if navigation.presentedViewController != nil {
            navigation.dismiss(animated: animated) {
                navigation.present(controller, animated: animated, completion: nil)
            }
        } else {
            navigation.present(controller, animated: animated, completion: nil)
        }
    }
    
    public func presentModal(_ controller: UIViewController, animated: Bool = true) {
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        
        present(controller, animated: animated)
    }
}
