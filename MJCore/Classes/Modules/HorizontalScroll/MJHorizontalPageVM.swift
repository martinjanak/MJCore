//
//  MJHorizontalPageVM.swift
//  MJCore
//
//  Created by Martin Janák on 03/07/2018.
//

import UIKit
import RxSwift

public class MJHorizontalPageVM: NSObject {
    
    private let disposeBag = DisposeBag()
    
    public let viewControllers = Variable([UIViewController]())
    public let currentVC = Variable<UIViewController?>(nil)
    
    private let countVariable = Variable<Int>(0)
    public lazy var count = countVariable
        .asObservable()
        .distinctUntilChanged()
    private let indexVariable = Variable<Int>(0)
    public lazy var index = indexVariable
        .asObservable()
        .distinctUntilChanged()
    
    private let changeSubject = PublishSubject<MJPageViewChange>()
    public lazy var change = changeSubject.asObservable()
    
    public let changeCompleted = PublishSubject<Bool>()
    
    public var viewControllersCount: Int {
        return viewControllers.value.count
    }
    
    public override init() {
        super.init()
        initBindings()
    }
    
    private func initBindings() {
        bindCount()
        bindViewControllers()
        bindIndex()
    }
    
    private func bindViewControllers() {
        viewControllers.asObservable()
            .map({ VCs in
                return MJPageViewChange(
                    viewController: VCs.count > 0 ? VCs[0] : nil,
                    direction: .forward,
                    animated: false
                )
            })
            .bind(to: changeSubject)
            .disposed(by: disposeBag)
    }
    
    private func bindCount() {
        viewControllers.asObservable()
            .map { $0.count }
            .bind(to: countVariable)
            .disposed(by: disposeBag)
    }
    
    private func bindIndex() {
        currentVC.asObservable()
            .withLatestFrom(
                viewControllers.asObservable(),
                resultSelector: { (currentVC, VCs) -> Int in
                    if let currentVC = currentVC,
                        VCs.count > 0,
                        let index = VCs.index(of: currentVC) {
                        return index
                    } else {
                        return 0
                    }
            }
            )
            .bind(to: indexVariable)
            .disposed(by: disposeBag)
    }
    
    private func getController(before viewController: UIViewController) -> UIViewController? {
        let viewControllersValue = viewControllers.value
        guard let viewControllerIndex = viewControllersValue.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        return viewControllersValue[previousIndex]
    }
    
    private func getController(after viewController: UIViewController) -> UIViewController? {
        let viewControllersValue = viewControllers.value
        guard let viewControllerIndex = viewControllersValue.index(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < viewControllersValue.count else {
            return nil
        }
        return viewControllersValue[nextIndex]
    }
    
}

extension MJHorizontalPageVM: UIPageViewControllerDataSource {
    
    // MARK: Prev
    
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
        return getController(before: viewController)
    }
    
    // MARK: Next
    
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
        return getController(after: viewController)
    }
}

extension MJHorizontalPageVM: UIPageViewControllerDelegate {
    
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
        ) {
        guard
            finished,
            completed,
            let viewController = pageViewController.viewControllers?.first
            else {
                return
        }
        currentVC.value = viewController
    }
    
}
