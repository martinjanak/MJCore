//
//  Observable+BatchParse.swift
//  MJCore
//
//  Created by Martin Janák on 19/07/2018.
//

import RxSwift

extension Observable where Element == MJResult<[Data]>  {
    
    public func batchParse<Model: MJsonParsable>(
        _ modelType: Model.Type,
        key: String? = nil,
        defaults: MJson? = nil
    ) -> Observable<MJResult<[Model]>> {
        return self.successMap { dataArray -> [Model] in
            var allParseSuccess = true
            var message = ""
            var models = [Model]()
            for data in dataArray {
                do {
                    models.append(try MJson.parseModel(
                        data,
                        key: key,
                        defaults: defaults
                    ))
                } catch let error {
                    allParseSuccess = false
                    message.append("{\(error)} ")
                }
            }
            if allParseSuccess {
                return models
            } else {
                throw MJObservableError.batch(message: message)
            }
        }
    }
    
    public func batchParse<Model: MJsonParsable>(
        _ modelType: [Model].Type,
        key: String? = nil,
        defaults: MJson? = nil
    ) -> Observable<MJResult<[[Model]]>> {
        return self.successMap { dataArray -> [[Model]] in
            var allParseSuccess = true
            var message = ""
            var models = [[Model]]()
            for data in dataArray {
                do {
                    models.append(try MJson.parseArrayModel(
                        data,
                        key: key,
                        defaults: defaults
                        ))
                } catch let error {
                    allParseSuccess = false
                    message.append("{\(error)} ")
                }
            }
            if allParseSuccess {
                return models
            } else {
                throw MJObservableError.batch(message: message)
            }
        }
    }
    
}
