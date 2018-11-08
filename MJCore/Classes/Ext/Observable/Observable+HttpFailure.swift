//
//  Observable+HttpFailure.swift
//  MJCore
//
//  Created by Martin Janák on 08/11/2018.
//

import RxSwift

extension Observable {
    
    public func onHttpFailure<ErrorModel: MJsonParsable>(
        _ modelType: ErrorModel.Type,
        handler: @escaping (Int, MJResult<ErrorModel>?) -> Void
    ) -> Observable<MJResult<Data>> where Element == MJResult<Data> {
        return self.map({ response in
            switch response {
            case .success:
                break
            case .failure(let error):
                if let httpError = error as? MJHttpError,
                    case .http(let statusCode, let dataOptional) = httpError {
                    if let data = dataOptional {
                        let result = MJResult<ErrorModel> {
                            return try MJson.parseModel(data)
                        }
                        handler(statusCode, result)
                    } else {
                        handler(statusCode, nil)
                    }
                }
            }
            return response
        })
    }
    
}
