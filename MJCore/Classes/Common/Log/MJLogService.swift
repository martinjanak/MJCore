//
//  MJLog.swift
//  MJCore
//
//  Created by Martin Janák on 26/05/2018.
//

import Foundation
import RxSwift

public protocol MJLogService: class {
    func info(_ tag: String, message: String) -> Observable<MJResultSimple>
    func error(_ tag: String, message: String) -> Observable<MJResultSimple>
}
