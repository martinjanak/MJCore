//
//  MJPoller.swift
//  MJCore
//
//  Created by Martin Janák on 24/05/2018.
//

import RxSwift

public final class MJBackgroundPoller {
    
    private let tickSubject = PublishSubject<MJResult<Double>>()
    public lazy var tick = tickSubject.asObservable()
    
    private let queue = DispatchQueue(
        label: "Poller",
        qos: .background
    )
    
    private var timer: Timer?
    private let interval: Double
    private var seconds: Double = 0
    private let timeout: Double?
    
    public init(interval: Double, timeout: Double? = nil) {
        self.interval = interval
        self.timeout = timeout
    }
    
    public func start() {
        queue.async {
            self.stopSync()
            self.timer = Timer(
                timeInterval: self.interval,
                target: self,
                selector: #selector(self.tickHandler),
                userInfo: nil,
                repeats: true
            )
            RunLoop.current.add(
                self.timer!,
                forMode: RunLoopMode.defaultRunLoopMode
            )
            RunLoop.current.run()
        }
    }
    
    public func stop() {
        queue.async {
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
        queue.sync {
            stopSync()
        }
    }
    
}
