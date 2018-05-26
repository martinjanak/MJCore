//
//  Observable+MJLog.swift
//  MJCore
//
//  Created by Martin Janák on 26/05/2018.
//

import RxSwift

extension Observable {
    
    public func log<V>(_ tag: String = "Result", log: MJLog) -> Observable<MJResult<V>> where Element == MJResult<V> {
        return self.do(onNext: { [weak weakLog = log] response in
            switch response {
            case .success:
                weakLog?.info(tag, message: "Success")
            case .failure(let error):
                weakLog?.error(tag, message: "\(error)")
            }
        })
    }
    
}

extension Observable where Element == MJResult<Data> {
    
    public func log(_ tag: String = "Result", log: MJLog) -> Observable<MJResult<Data>> {
        return self.do(onNext: { [weak weakLog = log] response in
            switch response {
            case .success(let data):
                if let json = MJson.parseOptional(data) {
                    weakLog?.info(tag, message: "Success: \(json)")
                } else if let jsonArray = MJson.parseArrayOptional(data) {
                    weakLog?.info(tag, message: "Success: \(jsonArray)")
                } else {
                    weakLog?.info(tag, message: "Success, but could not parse as JSON.")
                }
            case .failure(let error):
                weakLog?.error(tag, message: "Failure: \(error)")
            }
        })
    }
    
}

extension Observable where Element == MJResultSimple {
    
    public func log(_ tag: String = "Result", log: MJLog) -> Observable<MJResultSimple> {
        return self.do(onNext: { [weak weakLog = log] response in
            switch response {
            case .success:
                weakLog?.info(tag, message: "Success")
            case .failure(let error):
                weakLog?.error(tag, message: "Failure: \(error)")
            }
        })
    }
    
}
