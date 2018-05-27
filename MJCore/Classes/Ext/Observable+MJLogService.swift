//
//  Observable+MJLog.swift
//  MJCore
//
//  Created by Martin Janák on 26/05/2018.
//

import RxSwift

extension Observable {
    
    public func log<V>(_ tag: String = "Result", service: MJLogService) -> Observable<MJResult<V>> where Element == MJResult<V> {
        return self.do(onNext: { [weak weakService = service] response in
            switch response {
            case .success:
                weakService?.info(tag, message: "Success")
            case .failure(let error):
                weakService?.error(tag, message: "\(error)")
            }
        })
    }
    
}

extension Observable where Element == MJResult<Data> {
    
    public func log(_ tag: String = "Result", service: MJLogService) -> Observable<MJResult<Data>> {
        return self.do(onNext: { [weak weakService = service] response in
            switch response {
            case .success(let data):
                if let json = MJson.parseOptional(data) {
                    weakService?.info(tag, message: "Success: \(json)")
                } else if let jsonArray = MJson.parseArrayOptional(data) {
                    weakService?.info(tag, message: "Success: \(jsonArray)")
                } else {
                    weakService?.info(tag, message: "Success, but could not parse as JSON.")
                }
            case .failure(let error):
                weakService?.error(tag, message: "Failure: \(error)")
            }
        })
    }
    
}

extension Observable where Element == MJResultSimple {
    
    public func log(_ tag: String = "Result", service: MJLogService) -> Observable<MJResultSimple> {
        return self.do(onNext: { [weak weakService = service] response in
            switch response {
            case .success:
                weakService?.info(tag, message: "Success")
            case .failure(let error):
                weakService?.error(tag, message: "Failure: \(error)")
            }
        })
    }
    
}
