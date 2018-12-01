//
//  MJCountDownTimer.swift
//  MJCore
//
//  Created by Martin Janák on 15/08/2018.
//

import RxSwift
import RxCocoa

public final class MJCountDownTimer {
    
    private let disposeBag = DisposeBag()
    public let isRunning = BehaviorRelay(value: false)
    
    private let tickRelay = PublishRelay<Int>()
    public lazy var tick = tickRelay.asObservable()
    
    private let finishedRelay = PublishRelay<Void>()
    public lazy var finished = finishedRelay.asObservable()
    
    private let timeInterval: Int
    private var countdown: Int = 0
    
    public init(_ timeInterval: Int = 1) {
        if timeInterval < 1 {
            self.timeInterval = 1
            initBindings(1)
        } else {
            self.timeInterval = timeInterval
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
            .map { [weak self] tick -> Int in
                guard let strongSelf = self else { return 0 }
                return strongSelf.countdown - strongSelf.timeInterval * (tick + 1)
            }
            .bind(onNext: { [weak self] timeRemaining in
                if timeRemaining >= 0 {
                    self?.tickRelay.accept(timeRemaining)
                }
                if timeRemaining == 0 {
                    self?.finishedRelay.accept(())
                }
                if timeRemaining <= 0 {
                    self?.isRunning.accept(false)
                }
            })
            .disposed(by: disposeBag)
    }
    
    public func start(countdown: Int) {
        guard countdown >= timeInterval else { return }
        self.countdown = countdown
        isRunning.accept(true)
    }
    
    public func stop() {
        isRunning.accept(false)
    }
    
}
