//
//  Observable+Failure.swift
//  MJCore
//
//  Created by Martin Janák on 21/05/2018.
//

import RxSwift

extension Observable {
    
    public func failure<V>(
        _ handler: @escaping (Error) -> Void
    ) -> Observable<MJResult<V>> where Element == MJResult<V> {
        return self.map({ response in
            switch response {
            case .success:
                break
            case .failure(let error):
                handler(error)
            }
            return response
        })
    }
    
}

extension Observable where Element == MJResultSimple {
    
    public func failure(
        _ handler: @escaping (Error) -> Void
    ) -> Observable<MJResultSimple>  {
        return self.map({ response in
            switch response {
            case .success:
                break
            case .failure(let error):
                handler(error)
            }
            return response
        })
    }
    
    public func failureFlatMapSimple(
        _ handler: @escaping (Error) -> Observable<MJResultSimple>
    ) -> Observable<MJResultSimple> {
        return self.flatMap({ (response: MJResultSimple) -> Observable<MJResultSimple> in
            switch response {
            case .success:
                return .just(.success)
            case .failure(let error):
                return handler(error)
            }
        })
    }
    
}
