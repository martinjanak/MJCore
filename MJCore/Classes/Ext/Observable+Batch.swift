//
//  Observable+BatchParse.swift
//  MJCore
//
//  Created by Martin Janák on 19/07/2018.
//

import Foundation
import RxSwift

extension Observable {
    
    public static func batch<Value>(
        _ observables: [Observable<MJResult<Value>>]
    ) -> Observable<MJResult<[Value]>> {
        return Observable<MJResult<Value>>.combineLatest(observables)
            .map { (results: [MJResult<Value>]) -> MJResult<[Value]> in
                var allSuccess = true
                var message = ""
                var values = [Value]()
                for result in results {
                    switch result {
                    case .success(let value):
                        values.append(value)
                    case .failure(let error):
                        allSuccess = false
                        message.append("{\(error)} ")
                    }
                }
                if allSuccess {
                    return .success(value: values)
                } else {
                    return .failure(
                        error: MJObservableError.batch(message: message)
                    )
                }
        }
    }
    
    public static func batch<Value, Argument>(
        arguments: [Argument],
        task: @escaping (Argument) -> Observable<MJResult<Value>>
    ) -> Observable<MJResult<[Value]>> {
        let observables = arguments.map(task)
        return Observable.batch(observables)
    }
    
    public func batch<Value, Argument>(
        task: @escaping (Argument) -> Observable<MJResult<Value>>
    ) -> Observable<MJResult<[Value]>> where Element == MJResult<[Argument]> {
        return self.successFlatMap { values -> Observable<MJResult<[Value]>> in
            guard values.count > 0 else {
                return .just(.success(value: [Value]()))
            }
            return Observable.batch(arguments: values, task: task)
        }
    }
    
}
