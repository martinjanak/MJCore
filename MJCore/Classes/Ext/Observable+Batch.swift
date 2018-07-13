//
//  Observable+Batch.swift
//  MJCore
//
//  Created by Martin Janák on 04/06/2018.
//

import RxSwift

extension Observable {
    
    public static func batchResult(_ observables: [Observable<MJResultSimple>]) -> Observable<MJResultSimple> {
        return Observable<MJResultSimple>.combineLatest(observables)
            .map({ (results: [MJResultSimple]) -> MJResultSimple in
                var allSuccess = true
                var message = ""
                for result in results {
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        allSuccess = false
                        message.append("{\(error)} ")
                    }
                }
                if allSuccess {
                    return .success
                } else {
                    return .failure(
                        error: MJObservableError.batch(message: message)
                    )
                }
            })
    }
    
    public static func batchResult<V>(
        values: [V],
        task: @escaping (V) -> Observable<MJResultSimple>
    ) -> Observable<MJResultSimple> {
        let observables = values.map(task)
        return Observable.batchResult(observables)
    }
    
    public func batch<V>(
        task: @escaping (V) -> Observable<MJResultSimple>
    ) -> Observable<MJResultSimple> where Element == MJResult<[V]> {
        return self.successFlatMapSimple({ values -> Observable<MJResultSimple> in
            guard values.count > 0 else {
                return .just(.success)
            }
            return Observable.batchResult(values: values, task: task)
        })
    }
    
}
