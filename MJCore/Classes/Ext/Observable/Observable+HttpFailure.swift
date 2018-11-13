//
//  Observable+HttpFailure.swift
//  MJCore
//
//  Created by Martin Janák on 08/11/2018.
//

import RxSwift

extension Observable where Element == MJResult<Data> {
    
    public func onHttpFailure(
        handler: @escaping (Int, MJson?) -> Void
    ) -> Observable<MJResult<Data>> {
        return self.map({ response in
            switch response {
            case .success:
                break
            case .failure(let error):
                if let httpError = error as? MJHttpError,
                    case .http(let statusCode, let dataOptional) = httpError {
                    if let data = dataOptional, let json = MJson.parseOptional(data) {
                        handler(statusCode, json)
                    } else {
                        handler(statusCode, nil)
                    }
                }
            }
            return response
        })
    }
    
}
