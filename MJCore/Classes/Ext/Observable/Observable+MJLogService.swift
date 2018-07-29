//
//  Observable+MJLog.swift
//  MJCore
//
//  Created by Martin Janák on 26/05/2018.
//

import RxSwift

extension Observable {
    
    public func log<Value, LogService: MJLogService>(
        _ tag: String = "Result",
        service: LogService
    ) -> Observable<MJResult<Value>> where Element == MJResult<Value> {
        return self.flatMap({ [weak weakService = service] response -> Observable<MJResult<Value>> in
            switch response {
            case .success:
                return weakService?.info(tag, message: "Success")
                    .map({ _ in response })
                    ?? .just(response)
            case .failure(let error):
                return weakService?.error(tag, message: "\(error)")
                    .map({ _ in response })
                    ?? .just(response)
            }
        })
    }
    
}

extension Observable where Element == MJResult<Data> {
    
    public func log<LogService: MJLogService>(
        _ tag: String = "Result",
        service: LogService
    ) -> Observable<MJResult<Data>> {
        return self.flatMap({ [weak weakService = service] response -> Observable<MJResult<Data>> in
            switch response {
            case .success(let data):
                var message = ""
                if let json = MJson.parseOptional(data) {
                    message = "Success: Json = \(json)"
                } else if let jsonArray = MJson.parseArrayOptional(data) {
                    message = "Success: JsonArray = \(jsonArray)"
                } else {
                    message = "Success: Could not parse as JSON."
                }
                return weakService?.info(tag, message: message)
                    .map({ _ in response })
                    ?? .just(response)
            case .failure(let error):
                return weakService?.error(tag, message: "\(error)")
                    .map({ _ in response })
                    ?? .just(response)
            }
        })
    }
    
}

extension Observable where Element == MJResultSimple {
    
    public func log<LogService: MJLogService>(
        _ tag: String = "Result",
        service: LogService
    ) -> Observable<MJResultSimple> {
        return self.flatMap({ [weak weakService = service] response -> Observable<MJResultSimple> in
            switch response {
            case .success:
                return weakService?.info(tag, message: "Success")
                    .map({ _ in response })
                    ?? .just(response)
            case .failure(let error):
                return weakService?.error(tag, message: "\(error)")
                    .map({ _ in response })
                    ?? .just(response)
            }
        })
    }
    
}
