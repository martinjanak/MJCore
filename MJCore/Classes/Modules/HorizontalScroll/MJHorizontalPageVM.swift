//
//  MJHorizontalPageVM.swift
//  MJCore
//
//  Created by Martin Janák on 03/07/2018.
//

import UIKit
import RxSwift
import RxCocoa

public class MJHorizontalPageVM: NSObject {
    
    private let disposeBag = DisposeBag()
    
    public let viewControllers = BehaviorRelay(value: [UIViewController]())
    public let currentVC = BehaviorRelay<UIViewController?>(value: nil)
    
    private let countRelay = BehaviorRelay<Int>(value: 0)
    public lazy var count = countRelay
        .asObservable()
        .distinctUntilChanged()
    
    public let index = BehaviorRelay<Int>(value: 0)
    
    private let changeRelay = PublishRelay<MJPageViewChange>()
    public lazy var change = changeRelay.asObservable()
    
    public let changeCompleted = PublishRelay<Bool>()
    
    internal func initBindings() {
        bindCount()
        bindViewControllers()
        bindIndex()
        bindIndexSelection()
    }
    
    private func bindViewControllers() {
        viewControllers.asObservable()
            .filter { $0.count > 0 }
            .with(index.asObservable())
            .map { VCs, index in
                let initialIndex = (index >= 0 && index < VCs.count) ? index : 0
                return MJPageViewChange(
                    viewController: VCs[initialIndex],
                    direction: .forward,
                    animated: false
                )
            }
            .bind(to: changeRelay)
            .disposed(by: disposeBag)
    }
    
    private func bindCount() {
        viewControllers.asObservable()
            .map { $0.count }
            .bind(to: countRelay)
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
            .bind(to: index)
            .disposed(by: disposeBag)
    }
    
    private func bindIndexSelection() {
        index.asObservable()
            .distinctUntilChanged()
            .withLatestFrom(viewControllers.asObservable()) { ($0, $1) }
            .withLatestFrom(currentVC.asObservable()) { ($0.0, $0.1, $1) }
            .bind(onNext: { [weak self] index, controllers, currentVC in
                guard let currentVC = currentVC,
                    let currentIndex = controllers.index(of: currentVC),
                    index != currentIndex,
                    index < controllers.count,
                    index >= 0
                    else {
                    return
                }
                self?.changeRelay.accept(
                    MJPageViewChange(
                        viewController: controllers[index],
                        direction: index < currentIndex ? .reverse : .forward,
                        animated: true
                    )
                )
            })
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
        currentVC.accept(viewController)
    }
    
}
