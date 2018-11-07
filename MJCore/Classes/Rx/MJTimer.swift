//
//  MJTimer.swift
//  MJCore
//
//  Created by Martin Janák on 15/08/2018.
//

import RxSwift
import RxCocoa

public final class MJTimer {
    
    private let disposeBag = DisposeBag()
    public let isRunning = BehaviorRelay(value: false)
    
    private let tickRelay = PublishRelay<Int>()
    public lazy var tick = tickRelay.asObservable()
    
    public init(_ timeInterval: Int = 1) {
        if timeInterval < 1 {
            initBindings(1)
        } else {
            initBindings(timeInterval)
        }
    }
    
    private func initBindings(_ timeInterval: Int) {
        isRunning.asObservable()
            .flatMapLatest {  isRunning in
                return isRunning ? Observable<Int>.interval(
                    Double(timeInterval),
                    scheduler: MainScheduler.instance
                ) : .empty()
            }
            .map { timeInterval * ($0 + 1) }
            .bind(to: tickRelay)
            .disposed(by: disposeBag)
    }
    
    public func start() {
        isRunning.accept(true)
    }
    
    public func stop() {
        isRunning.accept(false)
    }
    
}
