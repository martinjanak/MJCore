//
//  Observable+Success.swift
//  MJCore
//
//  Created by Martin Janák on 21/05/2018.
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
    
    public func successMap<V, W>(
        _ handler: @escaping (V) -> W
    ) -> Observable<MJResult<W>> where Element == MJResult<V> {
        return self.map({ (response: MJResult<V>) -> MJResult<W> in
            switch response {
            case .success(let value):
                return .success(value: handler(value))
            case .failure(let error):
                return .failure(error: error)
            }
        })
    }
    
    public func successFlatMap<V, W>(
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
    
    public func successFlatMapSimple<V>(
        _ handler: @escaping (V) -> Observable<MJResultSimple>
    ) -> Observable<MJResultSimple> where Element == MJResult<V> {
        return self.flatMap({ (response: MJResult<V>) -> Observable<MJResultSimple> in
            switch response {
            case .success(let value):
                return handler(value)
            case .failure(let error):
                return Observable<MJResultSimple>.just(.failure(error: error))
            }
        })
    }
    
    public func bindSuccess<V, O: ObserverType>(
        to observer: O
    ) -> Disposable where O.E == V, Element == MJResult<V> {
        return self
            .map({ result -> V? in
                if case .success(let value) = result {
                    return value
                } else {
                    return nil
                }
            })
            .filter({ (value: V?) in
                return value != nil
            })
            .map({ (value: V?) -> V in
                return value!
            })
            .bind(to: observer)
    }
    
    public func bindSuccess<V>(
        to variable: Variable<V>
    ) -> Disposable where Element == MJResult<V> {
        return self
            .map({ result -> V? in
                if case .success(let value) = result {
                    return value
                } else {
                    return nil
                }
            })
            .filter({ (value: V?) in
                return value != nil
            })
            .map({ (value: V?) -> V in
                return value!
            })
            .bind(to: variable)
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
    
    public func successMap<W>(
        _ handler: @escaping () -> W
    ) -> Observable<MJResult<W>> {
        return self.map({ (response: MJResultSimple) -> MJResult<W> in
            switch response {
            case .success:
                return .success(value: handler())
            case .failure(let error):
                return .failure(error: error)
            }
        })
    }
    
    public func successFlatMap<W>(
        _ handler: @escaping () -> Observable<MJResult<W>>
    ) -> Observable<MJResult<W>> {
        return self.flatMap({ (response: MJResultSimple) -> Observable<MJResult<W>> in
            switch response {
            case .success:
                return handler()
            case .failure(let error):
                return Observable<MJResult<W>>.just(.failure(error: error))
            }
        })
    }
    
    public func successFlatMapSimple(
        _ handler: @escaping () -> Observable<MJResultSimple>
    ) -> Observable<MJResultSimple> {
        return self.flatMap({ (response: MJResultSimple) -> Observable<MJResultSimple> in
            switch response {
            case .success:
                return handler()
            case .failure(let error):
                return .just(.failure(error: error))
            }
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
    
}
