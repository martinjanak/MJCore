//
//  MJPoller.swift
//  MJCore
//
//  Created by Martin Janák on 28/05/2018.
//

import RxSwift

public enum MJPollerError: Error {
    case timeout
}

public final class MJPoller {
    
    private let tickSubject = PublishSubject<MJResult<Double>>()
    public lazy var tick = tickSubject.asObservable()
    
    private var timer: Timer?
    private let interval: Double
    private var seconds: Double = 0
    private let timeout: Double?
    
    public init(interval: Double, timeout: Double? = nil) {
        self.interval = interval
        self.timeout = timeout
    }
    
    public func start() {
        DispatchQueue.main.async {
            self.stopSync()
            self.timer = Timer.scheduledTimer(
                timeInterval: self.interval,
                target: self,
                selector: #selector(self.tickHandler),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    public func stop() {
        DispatchQueue.main.async {
            self.stopSync()
        }
    }
    
    private func stopSync() {
        timer?.invalidate()
        timer = nil
        seconds = 0
    }
    
    @objc
    private func tickHandler() {
        if let timeout = timeout, timeout <= seconds {
            tickSubject.onNext(.failure(error: MJPollerError.timeout))
            stopSync()
        } else {
            tickSubject.onNext(.success(value: seconds))
            seconds = seconds + interval
        }
    }
    
    deinit {
        stopSync()
    }
    
}
