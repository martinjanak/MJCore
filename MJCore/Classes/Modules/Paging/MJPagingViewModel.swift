//
//  MJPagingViewModel.swift
//  MJCore
//
//  Created by Martin Janák on 01/08/2018.
//

import UIKit
import RxSwift

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
    
    public typealias MJPageConstructor = (PagingModel) -> MJPageModule<PagingModel>
    
    private let privateScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "PagingQueue")
    private let disposeBag = DisposeBag()
    
    private var pageContructors = [String: MJPageConstructor]()
    
    public let pagingModels = Variable([PagingModel]())
    public let pageModules = Variable([MJPageModule<PagingModel>]())
    
    private let currentModuleVariable = Variable<MJPageModule<PagingModel>?>(nil)
    public lazy var currentModule = currentModuleVariable.asObservable()
    
    private let countVariable = Variable<Int>(0)
    public lazy var count = countVariable
        .asObservable()
        .distinctUntilChanged()
    
    private let currentIndexVariable = Variable<Int>(0)
    public lazy var currentIndex = currentIndexVariable.asObservable()
    
    private let changeSubject = PublishSubject<MJPagingChange?>()
    public lazy var change = changeSubject.asObservable()
    
    public let setIndex = PublishSubject<Int>()
    
    public let changeCompletedWith = PublishSubject<MJPageViewControllerType?>()
    
    internal func initBindings() {
        bindPagingModels()
        bindCount()
        bindIndexSelection()
        bindChangeCompletedWith()
        bindCurrentModule()
    }
    
    private func bindPagingModels() {
        pagingModels.asObservable()
            .observeOn(privateScheduler)
            .with(pageModules.asObservable())
            .map { [weak self] (pagingModels, pageModules) -> MJPagingChange? in
                guard let strongSelf = self else { return nil }
                
                let newSignature = pagingModels.map { $0.uniqueId }
                let oldSignature = pageModules.map { $0.uniqueId }
                
                if newSignature === oldSignature {
                    for i in 0..<pagingModels.count {
                        pageModules[i].pageViewModel.pagingModel.value = pagingModels[i]
                    }
                    return nil
                }
                
                var newModules = [MJPageModule<PagingModel>]()
                for pagingModel in pagingModels {
                    if let constructor = strongSelf.pageContructors[pagingModel.key] {
                        newModules.append(constructor(pagingModel))
                    }
                }
                strongSelf.pageModules.value = newModules
                
                return MJPagingChange(
                    viewController: newModules[0].viewController,
                    direction: .forward,
                    animated: false
                )
            }
            .bind(to: changeSubject)
            .disposed(by: disposeBag)
    }
    
    private func bindCount() {
        pageModules.asObservable()
            .observeOn(privateScheduler)
            .map { $0.count }
            .bind(to: countVariable)
            .disposed(by: disposeBag)
    }
    
    private func bindIndexSelection() {
        setIndex.asObservable()
            .observeOn(privateScheduler)
            .withLatestFrom(pageModules.asObservable()) { ($0, $1) }
            .withLatestFrom(currentIndexVariable.asObservable()) { ($0.0, $0.1, $1) }
            .bind(onNext: { [weak self] index, modules, currentIndex in
                guard
                    index != currentIndex,
                    0 <= index,
                    index < modules.count
                    else {
                        return
                }
                self?.changeSubject.onNext(
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
            .observeOn(privateScheduler)
            .unwrap()
            .with(pagingModels.asObservable())
            .map { (pageViewController, models) in
                return models.index(of: pageViewController) ?? 0
            }
            .bind(to: currentIndexVariable)
            .disposed(by: disposeBag)
    }
    
    private func bindCurrentModule() {
        currentIndexVariable.asObservable()
            .observeOn(privateScheduler)
            .with(pageModules.asObservable())
            .map { (currentIndex, modules) in
                return modules[currentIndex]
            }
            .bind(to: currentModuleVariable)
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
        Model: MJPageViewModel<PagingModel>,
        PageViewController: MJPageViewController<PagingModel, View, Model>
    >(
        _ type: PageViewController.Type
    ) {
        let key = PageViewController.key
        pageContructors[key] = { model in
            let pageVC = PageViewController(model)
            return MJPageModule<PagingModel>(
                viewController: pageVC,
                pageViewModel: pageVC.model
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
            currentIndexVariable.value = index
        }
    }
    
}
