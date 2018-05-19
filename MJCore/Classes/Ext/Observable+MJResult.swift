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
    
    public func successFlat<V, W>(
        _ handler: @escaping (V) -> Observable<MJResult<W>>
    ) -> Observable<MJResult<W>> where Element == MJResult<V> {
        return self.flatMap({ (response: MJResult<V>) -> Observable<MJResult<W>> in
            switch response {
            case .success(let value):
                return handler(value)
            case .failure(let error):
                return Observable<MJResult<W>>.just(.failure(error: error))
            }
        })
    }
    
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
    
    public func bindSuccess<V, O: ObserverType>(
        to observer: O
    ) -> Disposable where O.E == Bool, Element == MJResult<V> {
        return self
            .map({ $0.isSuccess() })
            .bind(to: observer)
    }
    
    public func bindSuccess<V>(
        to variable: Variable<Bool>
        ) -> Disposable where Element == MJResult<V> {
        return self
            .map({ $0.isSuccess() })
            .bind(to: variable)
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
    
    public func simplify<V>() -> Observable<MJResultSimple> where Element == MJResult<V> {
        return self.map({ $0.simplify() })
    }
    
}

extension Observable where Element == MJResult<Data> {
    
    public func debug(_ tag: String = "Result") -> Observable<MJResult<Data>> {
        return self.map({ response in
            switch response {
            case .success(let data):
                if let json = MJsonUtil.parseOptional(data) {
                    print("[\(tag)]: Success: \(json)")
                } else if let jsonArray = MJsonUtil.parseArrayOptional(data) {
                    print("[\(tag)]: Success: \(jsonArray)")
                } else {
                    print("[\(tag)]: Success, but could not parse as JSON.")
                }
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
    
    public func bindSuccess<O: ObserverType>(
        to observer: O
    ) -> Disposable where O.E == Bool {
        return self
            .map({ $0.isSuccess() })
            .bind(to: observer)
    }
    
    public func bindSuccess(
        to variable: Variable<Bool>
    ) -> Disposable {
        return self
            .map({ $0.isSuccess() })
            .bind(to: variable)
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
