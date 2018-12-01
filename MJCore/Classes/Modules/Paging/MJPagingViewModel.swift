//
//  MJPagingViewModel.swift
//  MJCore
//
//  Created by Martin Janák on 01/08/2018.
//

import UIKit
import RxSwift
import RxCocoa

public struct MJPageModule<PagingModel: MJPagingModelType>: MJPagingModelType {
    
    public let viewController: MJPageViewControllerType
    public let pageViewModel: MJPageViewModel<PagingModel>
    
    public var key: String {
        return pageViewModel.pagingModel.value?.key ?? ""
    }
    
    public var uniqueId: String {
        return pageViewModel.pagingModel.value?.uniqueId ?? ""
    }
    
}

public class MJPagingViewModel<PagingModel: MJPagingModelType>
    : NSObject
    , UIPageViewControllerDataSource
    , UIPageViewControllerDelegate {
    
    public typealias MJPageConstructor = (Int, PagingModel) -> MJPageModule<PagingModel>
    
    private let disposeBag = DisposeBag()
    
    private var pageContructors = [String: MJPageConstructor]()
    
    public let pagingModels = BehaviorRelay(value: [PagingModel]())
    public let pageModules = BehaviorRelay(value: [MJPageModule<PagingModel>]())
    
    private let currentModuleRelay = BehaviorRelay<MJPageModule<PagingModel>?>(value: nil)
    public lazy var currentModule = currentModuleRelay.asObservable()
    
    private let countRelay = BehaviorRelay<Int>(value: 0)
    public lazy var count = countRelay
        .asObservable()
        .distinctUntilChanged()
    
    private let currentIndexRelay = BehaviorRelay<Int?>(value: nil)
    public lazy var currentIndex = currentIndexRelay.asObservable()
    
    private let changeRelay = PublishRelay<MJPagingChange?>()
    public lazy var change = changeRelay.asObservable()
    
    public let setIndex = BehaviorRelay<Int?>(value: nil)
    
    public let changeCompletedWith = PublishRelay<MJPageViewControllerType?>()
    
    internal func initBindings() {
        bindPagingModels()
        bindCount()
        bindIndexSelection()
        bindChangeCompletedWith()
        bindCurrentModule()
    }
    
    private func bindPagingModels() {
        pagingModels.asObservable()
            .observeOn(MainScheduler.instance)
            .with(pageModules.asObservable())
            .withLatestFrom(setIndex.asObservable()) { ($0.0, $0.1, $1) }
            .map { [weak self] (pagingModels, pageModules, setIndex) -> MJPagingChange? in
                guard let strongSelf = self else { return nil }
                
                let newSignature = pagingModels.map { $0.uniqueId }
                let oldSignature = pageModules.map { $0.uniqueId }
                
                if newSignature ~~ oldSignature {
                    for i in 0..<pagingModels.count {
                        pageModules[i].pageViewModel.pagingModel.accept(pagingModels[i])
                    }
                    return nil
                }
                
                var newModules = [MJPageModule<PagingModel>]()
                for i in 0..<pagingModels.count {
                    if let constructor = strongSelf.pageContructors[pagingModels[i].key] {
                        newModules.append(constructor(i, pagingModels[i]))
                    }
                }
                strongSelf.pageModules.accept(newModules)
                
                guard newModules.count > 0 else {
                    return nil
                }
                
                if let setIndex = setIndex,
                    0 <= setIndex,
                    setIndex < newModules.count {
                    strongSelf.currentIndexRelay.accept(setIndex)
                    return MJPagingChange(
                        viewController: newModules[setIndex].viewController,
                        direction: .forward,
                        animated: false
                    )
                } else {
                    strongSelf.currentIndexRelay.accept(0)
                    return MJPagingChange(
                        viewController: newModules[0].viewController,
                        direction: .forward,
                        animated: false
                    )
                }
            }
            .bind(to: changeRelay)
            .disposed(by: disposeBag)
    }
    
    private func bindCount() {
        pageModules.asObservable()
            .observeOn(MainScheduler.instance)
            .map { $0.count }
            .bind(to: countRelay)
            .disposed(by: disposeBag)
    }
    
    private func bindIndexSelection() {
        setIndex.asObservable()
            .observeOn(MainScheduler.instance)
            .withLatestFrom(pageModules.asObservable()) { ($0, $1) }
            .withLatestFrom(currentIndexRelay.asObservable()) { ($0.0, $0.1, $1) }
            .bind(onNext: { [weak self] index, modules, currentIndex in
                guard
                    let index = index,
                    let currentIndex = currentIndex,
                    index != currentIndex,
                    0 <= index,
                    index < modules.count
                    else {
                        return
                }
                self?.changeRelay.accept(
                    MJPagingChange(
                        viewController: modules[index].viewController,
                        direction: index < currentIndex ? .reverse : .forward,
                        animated: true
                    )
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func bindChangeCompletedWith() {
        changeCompletedWith.asObservable()
            .observeOn(MainScheduler.instance)
            .unwrap()
            .with(pagingModels.asObservable())
            .map { (pageViewController, models) in
                return models.index(of: pageViewController) ?? 0
            }
            .bind(to: currentIndexRelay)
            .disposed(by: disposeBag)
    }
    
    private func bindCurrentModule() {
        currentIndexRelay.asObservable()
            .observeOn(MainScheduler.instance)
            .with(pageModules.asObservable())
            .map { (currentIndex, modules) -> MJPageModule<PagingModel>? in
                guard let currentIndex = currentIndex,
                    currentIndex < modules.count else {
                    return nil
                }
                return modules[currentIndex]
            }
            .bind(to: currentModuleRelay)
            .disposed(by: disposeBag)
    }
    
    private func getController(before viewController: UIViewController) -> UIViewController? {
        guard let pageViewController = viewController as? MJPageViewControllerType else {
            return nil
        }
        let modules = pageModules.value
        guard let index = modules.index(of: pageViewController) else {
            return nil
        }
        let previousIndex = index - 1
        guard previousIndex >= 0 else {
            return nil
        }
        return modules[previousIndex].viewController
    }
    
    private func getController(after viewController: UIViewController) -> UIViewController? {
        guard let pageViewController = viewController as? MJPageViewControllerType else {
            return nil
        }
        let modules = pageModules.value
        guard let index = modules.index(of: pageViewController) else {
            return nil
        }
        let nextIndex = index + 1
        guard nextIndex < modules.count else {
            return nil
        }
        return modules[nextIndex].viewController
    }
    
    public func register<
        View: MJView,
        ViewModel: MJPageViewModel<PagingModel>,
        PageViewController: MJPageViewController<PagingModel, View, ViewModel>
    >(
        _ type: PageViewController.Type,
        constructor: @escaping ((Int, PagingModel) -> PageViewController)
    ) {
        let key = PageViewController.getKey()
        pageContructors[key] = { index, paginModel in
            let pageVC = constructor(index, paginModel)
            return MJPageModule<PagingModel>(
                viewController: pageVC,
                pageViewModel: pageVC.viewModel
            )
        }
    }
    
    // MARK: Data source
    
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        return getController(before: viewController)
    }
    
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        return getController(after: viewController)
    }
    
    // MARK: Delegate
    
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard
            finished,
            completed,
            let pageViewController = pageViewController.viewControllers?.first as? MJPageViewControllerType
            else {
                return
        }
        let models = pagingModels.value
        if let index = models.index(of: pageViewController) {
            currentIndexRelay.accept(index)
        }
    }
    
}
