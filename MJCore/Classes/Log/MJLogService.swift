//
//  MJLog.swift
//  MJCore
//
//  Created by Martin Janák on 26/05/2018.
//

import Foundation
import RxSwift

public protocol HasLog {
    var log: MJLogService { get }
}

public final class MJLogService {
    
    private let infoSubject = PublishSubject<String>()
    public lazy var infoFeed = infoSubject.asObservable()
    
    private let errorSubject = PublishSubject<String>()
    public lazy var errorFeed = errorSubject.asObservable()
    
    public init() { }
    
    public func info(_ tag: String, message: String) {
        infoSubject.onNext("[\(tag)]: \(message)")
    }
    
    public func error(_ tag: String, message: String) {
        errorSubject.onNext("[\(tag)]: ERROR: \(message)")
    }
    
}
