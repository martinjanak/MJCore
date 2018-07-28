//
//  MJFlowController.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import UIKit
import RxSwift
import RxCocoa

open class MJFlowController<Service> {
    
    public weak var navigation: UINavigationController?
    public let service: Service
    
    public var endClosure: (() -> Void)?
    public weak var parentFlowController: MJFlowController<Service>?
    public var childFlowController: MJFlowController<Service>?
    
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
    
    public func end() {
        guard let endClosure = endClosure else {
            return
        }
        endClosure()
    }
    
    public func connect(_ flowController: MJFlowController<Service>) {
        guard
            let navigation = navigation,
            let currentVC = currentViewController
            else {
                return
        }
        flowController.endClosure = { [weak navigationWeak = navigation, weak currentVCWeak = currentVC] in
            guard
                let navigationStrong = navigationWeak,
                let currentVCStrong = currentVCWeak
                else {
                    return
            }
            navigationStrong.popToViewController(currentVCStrong, animated: true)
        }
        flowController.start(navigation: navigation)
    }
    
    public func present(
        _ flowController: MJFlowController<Service>,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let navigation = navigation else { return }
        childFlowController = flowController
        flowController.parentFlowController = self
        flowController.endClosure = { [weak flowControllerWeak = flowController, weak navigationWeak = navigation] in
            flowControllerWeak?.dismissBefore(animated: animated) {
                navigationWeak?.dismiss(animated: animated, completion: nil)
            }
        }
        let navigationController = UINavigationController()
        flowController.start(navigation: navigationController)
        navigation.present(
            navigationController,
            animated: animated,
            completion: completion
        )
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
        } else if navigation.viewControllers.count > 1 {
            navigation.popViewController(animated: animated)
        } else {
            end()
        }
    }
    
    public func enroot(
        _ controller: UIViewController,
        direction: UINavigationController.Direction? = nil,
        navBarHidden: Bool = false
    ) {
        dismissBefore(animated: direction != nil) {
            self.navigation?.setNavigationBarHidden(navBarHidden, animated: direction != nil)
            self.navigation?.set(root: controller, direction: direction)
        }
    }
    
    public func push(_ controller: UIViewController, animated: Bool = true, navBarHidden: Bool = false) {
        dismissBefore(animated: animated) {
            if self.navigation?.isNavigationBarHidden != navBarHidden {
                self.navigation?.setNavigationBarHidden(navBarHidden, animated: animated)
            }
            self.navigation?.pushViewController(controller, animated: animated)
        }
    }
    
    public func present(
        _ controller: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        dismissBefore(animated: animated) {
            self.navigation?.present(controller, animated: animated, completion: completion)
        }
    }
    
    public func present(flow: MJFlowController) {
        // todo
    }
    
    @discardableResult
    public func presentModal<View, Result>(
        _ controller: MJModalViewController<View, Result>,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Driver<Result> {
        
        let subject = PublishSubject<Result?>()
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.close = { result in
            self.back(animated: animated) {
                subject.onNext(result)
                subject.onCompleted()
            }
        }
        
        present(controller, animated: animated, completion: completion)
        return subject
            .asDriver(onErrorJustReturn: nil)
            .unwrap()
    }
    
    public func presentModally(
        _ controller: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        
        present(controller, animated: animated, completion: completion)
    }
    
    public func dismissBefore(animated: Bool, action: @escaping () -> Void) {
        if let navigation = navigation,
            navigation.presentedViewController != nil {
            navigation.dismiss(animated: animated) {
                action()
            }
        } else {
            action()
        }
    }
    
}
