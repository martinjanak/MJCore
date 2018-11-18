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
    
    public var endClosure: ((Bool) -> Void)?
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
    
    public func end(animated: Bool = true) {
        guard let endClosure = endClosure else {
            return
        }
        endClosure(animated)
    }
    
    public func connect(_ flowController: MJFlowController<Service>) {
        guard
            let navigation = navigation,
            let currentVC = currentViewController
            else {
                return
        }
        childFlowController = flowController
        flowController.parentFlowController = self
        flowController.endClosure = {
            [weak navigationWeak = navigation, weak currentVCWeak = currentVC] animated in
            guard
                let navigationStrong = navigationWeak,
                let currentVCStrong = currentVCWeak
                else {
                    return
            }
            navigationStrong.popToViewController(currentVCStrong, animated: animated)
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
        flowController.endClosure = {
            [weak flowControllerWeak = flowController, weak navigationWeak = navigation] animatedEnd in
            flowControllerWeak?.dismissBefore(animated: animatedEnd) {
                navigationWeak?.dismiss(animated: animatedEnd, completion: nil)
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
    
    public func presentModally(
        _ flowController: MJFlowController<Service>,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let navigation = navigation else { return }
        childFlowController = flowController
        flowController.parentFlowController = self
        flowController.endClosure = {
            [weak flowControllerWeak = flowController, weak navigationWeak = navigation] animatedEnd in
            flowControllerWeak?.dismissBefore(animated: animatedEnd) {
                navigationWeak?.dismiss(animated: animatedEnd, completion: nil)
            }
        }
        let navigationController = UINavigationController()
        flowController.start(navigation: navigationController)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.modalTransitionStyle = .crossDissolve
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
    
    public func presentWithResult<View, ViewModel, Result>(
        _ controller: MJResultViewController<View, ViewModel, Result>,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Observable<Result> {
        
        present(controller, animated: animated, completion: completion)
        
        return Observable.create { [weak self, weak controller] observer in
            guard let controller = controller else {
                return Disposables.create()
            }
            controller.close = { [weak self] result in
                self?.back(animated: animated) {
                    observer.onNext(result)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
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
