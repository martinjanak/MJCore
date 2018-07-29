//
//  Observable+Debug.swift
//  MJCore
//
//  Created by Martin Janák on 21/05/2018.
//

import RxSwift

extension Observable {
    
    public func debug<V>(_ tag: String = "Result") -> Observable<MJResult<V>> where Element == MJResult<V> {
        return self.do(onNext: { response in
            switch response {
            case .success:
                print("[\(tag)]: Success")
            case .failure(let error):
                print("[\(tag)]: Failure: \(error)")
            }
        })
    }
    
}

extension Observable where Element == MJResult<Data> {
    
    public func debug(_ tag: String = "Result") -> Observable<MJResult<Data>> {
        return self.do(onNext: { response in
            switch response {
            case .success(let data):
                if let json = MJson.parseOptional(data) {
                    print("[\(tag)]: Success: \(json)")
                } else if let jsonArray = MJson.parseArrayOptional(data) {
                    print("[\(tag)]: Success: \(jsonArray)")
                } else {
                    print("[\(tag)]: Success, but could not parse as JSON.")
                }
            case .failure(let error):
                print("[\(tag)]: Failure: \(error)")
            }
        })
    }
    
}

extension Observable where Element == MJResultSimple {
    
    public func debug(_ tag: String = "Result") -> Observable<MJResultSimple> {
        return self.do(onNext: { response in
            switch response {
            case .success:
                print("[\(tag)]: Success")
            case .failure(let error):
                print("[\(tag)]: Failure: \(error)")
            }
        })
    }
    
}
