//
//  Observable+Batch.swift
//  MJCore
//
//  Created by Martin Janák on 04/06/2018.
//

import Foundation
import RxSwift

extension Observable {
    
    public static func batchResult(
        _ observables: [Observable<MJResultSimple>]
    ) -> Observable<MJResultSimple> {
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
    
//    public static func batchParse<Model: MJsonParsable>(
//        _ modelType: Model.Type,
//        observables: [MJHttpResponse]
//    ) -> Observable<MJResult<[Model]>> {
//        return MJHttpResponse.combineLatest(observables)
//            .map { (results: [MJResult<Data>]) -> MJResult<[Model]> in
//                var allSuccess = true
//                var message = ""
//                var dataArray = [Data]()
//                for result in results {
//                    switch result {
//                    case .success(let data):
//                        dataArray.append(data)
//                    case .failure(let error):
//                        allSuccess = false
//                        message.append("{\(error)} ")
//                    }
//                }
//                if allSuccess {
                    
//                } else {
//                    return .failure(
//                        error: MJObservableError.batch(message: message)
//                    )
//                }
//            }
//    }
    
    public static func batchResult<Argument>(
        arguments: [Argument],
        task: @escaping (Argument) -> Observable<MJResultSimple>
    ) -> Observable<MJResultSimple> {
        let observables = arguments.map(task)
        return Observable.batchResult(observables)
    }
    
    public func batchResult<Argument>(
        task: @escaping (Argument) -> Observable<MJResultSimple>
    ) -> Observable<MJResultSimple> where Element == MJResult<[Argument]> {
        return self.successFlatMapSimple({ arguments -> Observable<MJResultSimple> in
            guard arguments.count > 0 else {
                return .just(.success)
            }
            return Observable.batchResult(arguments: arguments, task: task)
        })
    }
    
}
