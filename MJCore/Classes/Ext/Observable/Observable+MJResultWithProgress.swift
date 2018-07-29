//
//  Observable+MJResultWithProgress.swift
//  MJCore
//
//  Created by Martin Janák on 16/05/2018.
//

import RxSwift

extension Observable {
    
    public func success<V, P>(
        _ handler: @escaping (V) -> Void
    ) -> Observable<MJResultWithProgress<V, P>> where Element == MJResultWithProgress<V, P> {
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
    
    public func progress<V, P>(
        _ handler: @escaping (P) -> Void
    ) -> Observable<MJResultWithProgress<V, P>> where Element == MJResultWithProgress<V, P> {
        return self.map({ response in
            switch response {
            case .progress(let value):
                handler(value)
            default:
                break
            }
            return response
        })
    }
    
    public func failure<V, P>(
        _ handler: @escaping (Error) -> Void
    ) -> Observable<MJResultWithProgress<V, P>> where Element == MJResultWithProgress<V, P> {
        return self.map({ response in
            switch response {
            case .failure(let error):
                handler(error)
            default:
                break
            }
            return response
        })
    }
    
    public func bindSuccess<V, P, O: ObserverType>(
        to observer: O
    ) -> Disposable where O.E == Bool, Element == MJResultWithProgress<V, P> {
        return self
            .map({ $0.isSuccess() })
            .bind(to: observer)
    }
    
    public func bindSuccess<V, P>(
        to variable: Variable<Bool>
    ) -> Disposable where Element == MJResultWithProgress<V, P> {
        return self
            .map({ $0.isSuccess() })
            .bind(to: variable)
    }
    
    public func debug<V, P>(_ tag: String = "Result") -> Observable<MJResultWithProgress<V, P>> where Element == MJResultWithProgress<V, P> {
        return self.map({ response in
            switch response {
            case .success:
                print("[\(tag)]: Success")
            case .progress(let value):
                print("[\(tag)]: Progress: \(value)")
            case .failure(let error):
                print("[\(tag)]: Failure: \(error)")
            }
            return response
        })
    }
    
    public func simplify<V, P>() -> Observable<MJResultWithProgressSimple<P>> where Element == MJResultWithProgress<V, P> {
        return self.map({ $0.simplify() })
    }
    
}

extension Observable {
    
    public func success<P>(
        _ handler: @escaping () -> Void
    ) -> Observable<MJResultWithProgressSimple<P>> where Element == MJResultWithProgressSimple<P> {
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
    
    public func progress<P>(
        _ handler: @escaping (P) -> Void
    ) -> Observable<MJResultWithProgressSimple<P>> where Element == MJResultWithProgressSimple<P> {
        return self.map({ response in
            switch response {
            case .progress(let value):
                handler(value)
            default:
                break
            }
            return response
        })
    }
    
    public func failure<P>(
        _ handler: @escaping (Error) -> Void
    ) -> Observable<MJResultWithProgressSimple<P>> where Element == MJResultWithProgressSimple<P> {
        return self.map({ response in
            switch response {
            case .failure(let error):
                handler(error)
            default:
                break
            }
            return response
        })
    }
    
    public func bindSuccess<P, O: ObserverType>(
        to observer: O
    ) -> Disposable where O.E == Bool, Element == MJResultWithProgressSimple<P> {
        return self
            .map({ $0.isSuccess() })
            .bind(to: observer)
    }
    
    public func bindSuccess<P>(
        to variable: Variable<Bool>
    ) -> Disposable where Element == MJResultWithProgressSimple<P> {
        return self
            .map({ $0.isSuccess() })
            .bind(to: variable)
    }
    
    public func debug<P>(_ tag: String = "Result") -> Observable<MJResultWithProgressSimple<P>> where Element == MJResultWithProgressSimple<P> {
        return self.map({ response in
            switch response {
            case .success:
                print("[\(tag)]: Success")
            case .progress(let value):
                print("[\(tag)]: Progress: \(value)")
            case .failure(let error):
                print("[\(tag)]: Failure: \(error)")
            }
            return response
        })
    }
    
}
