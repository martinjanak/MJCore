//
//  Observable+MJHttpResponse.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import RxSwift

extension Observable {
    
    public func success<V>(
        _ handler: @escaping (V) -> Void
    ) -> Observable<MJResult<V>> where Element == MJResult<V> {
        return self.map({ response in
            switch response {
            case .success(let value):
                handler(value)
            default:
                break
            }
            return response
        })
    }
    
    public func `catch`<V>(
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
    
    public func debug<V>(_ tag: String = "Result") -> Observable<MJResult<V>> where Element == MJResult<V> {
        return self.map({ response in
            switch response {
            case .success:
                print("[\(tag)]: Success")
            case .failure(let error):
                print("[\(tag)]: Failure: \(error)")
            }
            return response
        })
    }
    
}

extension Observable where Element == MJResultSimple {
    
    public func success(
        _ handler: @escaping () -> Void
    ) -> Observable<MJResultSimple> {
        return self.map({ response in
            switch response {
            case .success:
                handler()
            default:
                break
            }
            return response
        })
    }
    
    public func `catch`(
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
    
    public func debug(_ tag: String = "Result") -> Observable<MJResultSimple> {
        return self.map({ response in
            switch response {
            case .success:
                print("[\(tag)]: Success")
            case .failure(let error):
                print("[\(tag)]: Failure: \(error)")
            }
            return response
        })
    }
    
}
