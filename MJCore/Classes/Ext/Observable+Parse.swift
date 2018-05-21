//
//  Observable+Parse.swift
//  MJCore
//
//  Created by Martin Janák on 21/05/2018.
//

import RxSwift

extension Observable where Element == MJResult<Data> {
    
    public func parse<Model: MJsonParsable>(_ modelType: Model.Type) -> Observable<MJResult<Model>> {
        return self.successMap({ data in
            return MJResult { () -> Model in
                let json = try MJson.parse(data)
                return try Model(json: json)
            }
        })
    }
    
    public func parse<Model: MJsonParsable>(_ modelType: [Model].Type) -> Observable<MJResult<[Model]>> {
        return self.successMap({ data in
            return MJResult { () -> [Model] in
                let jsonArray = try MJson.parseArray(data)
                var modelArray = [Model]()
                for json in jsonArray {
                    modelArray.append(try Model(json: json))
                }
                return modelArray
            }
        })
    }
    
    public func parseOptional<Model: MJsonParsable>(_ modelType: Model.Type) -> Observable<Model?> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    let json = try MJson.parse(data)
                    return try Model(json: json)
                } catch {
                    return nil
                }
            default:
                return nil
            }
        })
    }
    
    public func parseOptional<Model: MJsonParsable>(_ modelType: [Model].Type) -> Observable<[Model]?> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    let jsonArray = try MJson.parseArray(data)
                    var modelArray = [Model]()
                    for json in jsonArray {
                        modelArray.append(try Model(json: json))
                    }
                    return modelArray
                } catch {
                    return nil
                }
            default:
                return nil
            }
        })
    }
    
    public func parse<Model: MJsonParsable>(_ modelType: Model.Type, defaultValue: Model) -> Observable<Model> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    let json = try MJson.parse(data)
                    return try Model(json: json)
                } catch {
                    return defaultValue
                }
            default:
                return defaultValue
            }
        })
    }
    
    public func parse<Model: MJsonParsable>(_ modelType: [Model].Type, defaultValue: [Model]) -> Observable<[Model]> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    let jsonArray = try MJson.parseArray(data)
                    var modelArray = [Model]()
                    for json in jsonArray {
                        modelArray.append(try Model(json: json))
                    }
                    return modelArray
                } catch {
                    return defaultValue
                }
            default:
                return defaultValue
            }
        })
    }
    
}
