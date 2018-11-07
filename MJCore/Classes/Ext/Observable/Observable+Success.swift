//
//  Observable+Success.swift
//  MJCore
//
//  Created by Martin Janák on 21/05/2018.
//

import RxSwift
import RxCocoa

extension Observable {
    
    public func onSuccess<V>(
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
    
    public func onSuccessAwait<V>(
        _ handler: @escaping (V) -> Observable<MJResultSimple>
    ) -> Observable<MJResult<V>> where Element == MJResult<V> {
        return self.flatMap({ (response: MJResult<V>) -> Observable<MJResult<V>> in
            switch response {
            case .success(let value):
                return handler(value)
                    .map { _ in response }
            case .failure:
                return .just(response)
            }
        })
    }
    
    public func successMap<V, W>(
        _ handler: @escaping (V) throws -> W
    ) -> Observable<MJResult<W>> where Element == MJResult<V> {
        return self.map({ (response: MJResult<V>) -> MJResult<W> in
            switch response {
            case .success(let value):
                return MJResult{ try handler(value) }
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
        to relay: BehaviorRelay<V>
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
            .bind(to: relay)
    }
    
    public func bindSuccess<V>(
        _ handler: @escaping (V) -> Void
    ) -> Disposable where Element == MJResult<V> {
        return self.bind(onNext: { result in
            if case .success(let value) = result {
                handler(value)
            }
        })
    }
    
}

extension Observable where Element == MJResultSimple {
    
    public func onSuccess(
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
    
    public func onSuccessAwait(
        _ handler: @escaping () -> Observable<MJResultSimple>
    ) -> Observable<MJResultSimple> {
        return self.flatMap({ (response: MJResultSimple) -> Observable<MJResultSimple> in
            switch response {
            case .success:
                return handler()
                    .map { _ in response }
            case .failure:
                return .just(response)
            }
        })
    }
    
    public func successMap<W>(
        _ handler: @escaping () throws -> W
    ) -> Observable<MJResult<W>> {
        return self.map({ (response: MJResultSimple) -> MJResult<W> in
            switch response {
            case .success:
                return MJResult{ try handler() }
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
        to relay: BehaviorRelay<Bool>
    ) -> Disposable {
        return self
            .map({ $0.isSuccess() })
            .bind(to: relay)
    }
    
    public func bindSuccess(
        _ handler: @escaping () -> Void
    ) -> Disposable {
        return self.bind(onNext: { result in
            if case .success = result {
                handler()
            }
        })
    }
    
}
