//
//  MJHorizontalPageVC.swift
//  MJCore
//
//  Created by Martin Janák on 03/07/2018.
//

import UIKit
import RxSwift

public struct MJPageViewChange {
    
    let viewController: UIViewController?
    let direction: UIPageViewControllerNavigationDirection
    let animated: Bool
    
    static func error() -> MJPageViewChange {
        return MJPageViewChange(
            viewController: UIViewController(),
            direction: .forward,
            animated: false
        )
    }
}

public final class MJHorizontalPageVC: UIPageViewController {
    
    private let disposeBag = DisposeBag()
    let model = MJHorizontalPageVM()
    
    override init(
        transitionStyle style: UIPageViewControllerTransitionStyle,
        navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String: Any]? = nil
    ) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        delegate = model
        dataSource = model
        
        model.change
            .asDriver(onErrorJustReturn: MJPageViewChange.error())
            .drive(onNext: { [weak self] pageViewChange in
                var viewControllers: [UIViewController]
                if let viewController = pageViewChange.viewController {
                    viewControllers = [viewController]
                } else {
                    viewControllers = []
                }
                self?.setViewControllers(
                    viewControllers,
                    direction: pageViewChange.direction,
                    animated: pageViewChange.animated,
                    completion: { _ in
                        self?.model.changeCompleted.onNext(true)
                        self?.model.currentVC.value = pageViewChange.viewController
                }
                )
            })
            .disposed(by: disposeBag)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
