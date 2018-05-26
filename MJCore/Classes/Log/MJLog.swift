//
//  MJLog.swift
//  MJCore
//
//  Created by Martin Janák on 26/05/2018.
//

import Foundation
import RxSwift

public protocol HasLog {
    var log: MJLog { get }
}

public final class MJLog {
    
    private let infoSubject = PublishSubject<String>()
    lazy var infoFeed = infoSubject.asObservable()
    
    private let errorSubject = PublishSubject<String>()
    lazy var errorFeed = errorSubject.asObservable()
    
    func info(_ tag: String, message: String) {
        infoSubject.onNext("[\(tag)]: \(message)")
    }
    
    func error(_ tag: String, message: String) {
        errorSubject.onNext("[\(tag)]: ERROR: \(message)")
    }
    
}
